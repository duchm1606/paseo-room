"""Regression tests for exact-workspace grants in the original role gate."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOM = Path(__file__).resolve().parents[1]
TRUSTYBOT = "/home/ubuntu/projects/trustybot-duckling"


class WorkspaceGrantsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.room = self.root / "room"
        for directory in ("hooks", "droid", "protocol"):
            (self.room / directory).mkdir(parents=True)
        for name in ("hooks/role-gate.sh", "droid/role-gate.sh"):
            shutil.copyfile(ROOM / name, self.room / name)
        self.workspace = self.root / "workspace"
        self.workspace.mkdir()
        self.other = self.root / "workspace-other"
        self.other.mkdir()
        self.grants = self.room / "protocol/workspace-skill-grants.json"
        self.grants.write_text(json.dumps({
            str(self.workspace): {
                "lead": ["ticket-delivery", "dual-review"],
                "peer": ["browser-harness"],
            },
        }))

    def call(self, role, skill=None, cwd=None, tool="Skill", inputs=None, droid=False):
        payload = {
            "tool_name": tool,
            "tool_input": inputs if inputs is not None else {"skill": skill},
        }
        if cwd is not None:
            payload["cwd"] = str(cwd)
        gate = self.room / ("droid/role-gate.sh" if droid else "hooks/role-gate.sh")
        result = subprocess.run(
            ["bash", str(gate)],
            input=json.dumps(payload), text=True, capture_output=True,
            env={**os.environ, "ROOM_ROLE": role}, check=True, timeout=10,
        )
        if not result.stdout.strip():
            return "allow"
        return json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"]

    def test_live_registry_is_narrow(self):
        registry = json.loads((ROOM / "protocol/workspace-skill-grants.json").read_text())
        self.assertEqual(registry, {
            TRUSTYBOT: {
                "lead": ["ticket-delivery"],
                "peer": ["browser-harness", "open-code-review:delegate-review"],
            },
        })

    def test_original_claude_and_droid_entrypoints(self):
        for droid in (False, True):
            for role, skill in (
                ("lead", "ticket-delivery"), ("lead", "dual-review"),
                ("peer", "browser-harness"),
            ):
                with self.subTest(droid=droid, role=role, skill=skill):
                    self.assertEqual(self.call(role, skill, self.workspace, droid=droid), "allow")

    def test_wrong_roles_denied(self):
        for role, skill in (
            ("peer", "ticket-delivery"), ("peer", "dual-review"),
            ("lead", "browser-harness"), ("supervisor", "ticket-delivery"),
            ("supervisor", "dual-review"), ("supervisor", "browser-harness"),
        ):
            self.assertEqual(self.call(role, skill, self.workspace), "deny")

    def test_missing_relative_sibling_and_child_paths_denied(self):
        child = self.workspace / "child"
        child.mkdir()
        # browser-harness is on the Peer allow-list everywhere; probe the path
        # rules with a Peer skill that only a grant can give.
        self.grants.write_text(json.dumps({
            str(self.workspace): {
                "lead": ["ticket-delivery"],
                "peer": ["open-code-review:delegate-review"],
            },
        }))
        self.assertEqual(self.call("peer", "open-code-review:delegate-review", self.workspace), "allow")
        for cwd in (None, "", "relative", self.other, child, self.root / "missing"):
            for role, skill in (("lead", "ticket-delivery"), ("peer", "open-code-review:delegate-review")):
                self.assertEqual(self.call(role, skill, cwd), "deny")

    def test_canonical_paths_and_symlink_escape(self):
        alias = self.root / "alias"
        alias.symlink_to(self.workspace, target_is_directory=True)
        escape = self.workspace / "escape"
        escape.symlink_to(self.other, target_is_directory=True)
        self.assertEqual(self.call("lead", "dual-review", alias), "allow")
        self.assertEqual(self.call("lead", "dual-review", escape), "deny")
        self.assertEqual(self.call("lead", "dual-review", self.workspace / ".."), "deny")

    def test_no_namespaced_or_prefix_grants(self):
        for skill in ("plugin:ticket-delivery", "ticket-delivery-extra", "browser-harness-extra"):
            self.assertEqual(self.call("lead", skill, self.workspace), "deny")

    def test_missing_or_invalid_registry_cannot_grant(self):
        for content in ('{broken', '{"unused": {}}', json.dumps({str(self.workspace): {"lead": "ticket-delivery"}})):
            self.grants.write_text(content)
            self.assertEqual(self.call("lead", "ticket-delivery", self.workspace), "deny")
        self.grants.unlink()
        self.assertEqual(self.call("lead", "ticket-delivery", self.workspace), "deny")
        self.assertEqual(self.call("peer", "research", self.workspace), "allow")

    def test_global_denials_win_even_if_registry_grants_them(self):
        self.grants.write_text(json.dumps({str(self.workspace): {"lead": ["ultra-review", "code-review"]}}))
        for skill in ("ultra-review", "code-review"):
            self.assertEqual(self.call("lead", skill, self.workspace), "deny")
        for tool in ("Task", "Agent", "Workflow"):
            self.assertEqual(self.call("lead", cwd=self.workspace, tool=tool, inputs={}), "deny")

    def test_ocr_and_memory_rules_unchanged(self):
        self.assertEqual(self.call("peer", cwd=self.workspace, tool="Bash", inputs={"command": "ocr --help"}), "deny")
        self.assertEqual(self.call(
            "lead", cwd=self.workspace, tool="Write",
            inputs={"file_path": str(Path.home() / ".claude/projects/x/memory/a.md")},
        ), "deny")

    def test_other_workspace_and_human_behavior_unchanged(self):
        for cwd in (self.workspace, self.other, None):
            self.assertEqual(self.call("peer", "research", cwd), "allow")
            self.assertEqual(self.call("lead", "triple-review", cwd), "allow")
            self.assertEqual(self.call("", "ticket-delivery", cwd), "allow")
            self.assertEqual(self.call("lead", "unknown-skill", cwd), "deny")
        # A project cannot grant itself privileges by adding its own registry.
        (self.other / "workspace-skill-grants.json").write_text(json.dumps({
            str(self.other): {"lead": ["ticket-delivery"]},
        }))
        self.assertEqual(self.call("lead", "ticket-delivery", self.other), "deny")


    def grant_ocr(self):
        self.grants.write_text(json.dumps({
            str(self.workspace): {
                "lead": ["ticket-delivery", "dual-review"],
                "peer": ["browser-harness", "open-code-review:delegate-review"],
            },
        }))

    def bash(self, role, command, cwd=None, droid=False):
        return self.call(
            role, cwd=self.workspace if cwd is None else cwd,
            tool="Execute" if droid else "Bash", inputs={"command": command}, droid=droid,
        )

    def test_ocr_delegate_granted_claude_peer_only(self):
        self.grant_ocr()
        for command in (
            "ocr delegate preview --repo trustybot-backend --from develop --to HEAD",
            "ocr d preview -f json",
            "ocr delegate rule src/a.py src/b.py",
            "ocr --version", "ocr delegate --help",
            "cd x && ocr delegate preview && ocr delegate rule a.py",
        ):
            with self.subTest(command=command):
                self.assertEqual(self.bash("peer", command), "allow")
        self.assertEqual(self.call("peer", "open-code-review:delegate-review", self.workspace), "allow")

    def test_ocr_non_delegate_commands_denied(self):
        self.grant_ocr()
        for command in (
            "ocr review", "ocr review --audience agent", "ocr", "ocr scan .",
            "ocr config set x y", "ocr delegate", "ocr delegate preview;ocr review",
            "ocr delegate preview && ocr review", "ocr delegate preview | ocr llm",
            "ocr delegate preview ocr review", "ocr delegate previewx",
        ):
            with self.subTest(command=command):
                self.assertEqual(self.bash("peer", command), "deny")
        self.assertEqual(self.call("peer", "open-code-review:review", self.workspace), "deny")

    def test_ocr_delegate_denied_without_grant_or_seat(self):
        self.grant_ocr()
        command = "ocr delegate preview"
        child = self.workspace / "child"
        child.mkdir()
        for role in ("lead", "supervisor"):
            self.assertEqual(self.bash(role, command), "deny")
        for cwd in (self.other, child, ""):
            self.assertEqual(self.bash("peer", command, cwd=cwd), "deny")
        self.assertEqual(self.bash("peer", command, droid=True), "deny")
        self.grants.write_text(json.dumps({str(self.workspace): {"peer": ["browser-harness"]}}))
        self.assertEqual(self.bash("peer", command), "deny")


if __name__ == "__main__":
    unittest.main()
