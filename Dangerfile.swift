
import Danger

let danger = Danger()

// Pull request size
let bigPRThreshold = 500
let additions = danger.github.pullRequest.additions!
let deletions = danger.github.pullRequest.deletions!
let changedFiles = danger.github.pullRequest.changedFiles!
if (additions + deletions > bigPRThreshold) {
    warn("PR size seems relatively large. ✂️ If this PR contains multiple changes, please split each into separate PR will helps faster, easier review.")
}

// Pull request body validation
if danger.github.pullRequest.body == nil || danger.github.pullRequest.body!.isEmpty {
    warn("PR has no description. 📝 You should provide a description of the changes that have made.")
}

// Pull request title validation
let prTitle = danger.github.pullRequest.title
if prTitle.contains("WIP") {
    warn("PR is classed as _Work in Progress_.")
}
if prTitle.count < 5 {
    warn("PR title is too short. 🙏 Please use this format `[SDK-000] Your feature title` and replace `000` with Jira task number.")
}
if !prTitle.contains("[SDK-") {
    warn("PR title does not containe the related Jira task. 🙏 Please use this format `[SDK-000] Your feature title` and replace `000` with Jira task number.")
}

// Files changed and created should includes unit tests
let modified = danger.git.modifiedFiles
let editedFiles = modified + danger.git.createdFiles
let testFiles = editedFiles.filter { ($0.contains("Tests") || $0.contains("Test")) && ($0.fileType == .swift  || $0.fileType == .m) }
if testFiles.isEmpty {
    warn("PR does not contain any files related to unit tests ✅ (ignore if your changes do not require tests)")
}

message("🎉 The PR added \(additions) and removed \(deletions) lines. 🗂 \(changedFiles) files changed.")
view rawDangerfile.swift hosted with ❤ by GitHub
