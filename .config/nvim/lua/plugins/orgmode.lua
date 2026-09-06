-- Org-mode
return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("orgmode").setup({
			org_agenda_files = { "~/org/**/*.org", "~/org/*.org" },
			org_default_notes_file = "~/org/notes.org",

			-- Doom: (sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)")
			org_todo_keywords = { "TODO(t)", "WAIT(w)", "|", "DONE(d)", "SOMEDAY(s)" },

			-- Doom: org-log-done 'time / org-log-into-drawer t / org-hide-emphasis-markers t
			--       +org モジュールの org-startup-folded 'showeverything
			org_log_done = "time",
			org_log_into_drawer = "LOGBOOK",
			org_hide_emphasis_markers = true,
			org_startup_folded = "showeverything",

			-- Doom の org-capture-templates に対応
			org_capture_templates = {
				i = {
					description = "Inbox",
					template = "** TODO %?\n%a",
					target = "~/org/todo.org",
					headline = "Inbox",
				},
				t = {
					description = "Personal todo",
					template = "* [ ] %?\n%a",
					target = "~/org/todo.org",
					headline = "Inbox",
				},
				n = {
					description = "Personal notes",
					template = "* %u %?\n%a",
					target = "~/org/notes.org",
					headline = "Inbox",
				},
				j = {
					description = "Journal",
					template = "* %U %?",
					target = "~/org/journal.org",
					datetree = true, 
				},
				d = {
					description = "Daily Task",
					template = "* TODO %?",
					target = "~/org/tasks.org",
					datetree = {
						tree_type = "custom",
						tree = {
							{
								format = "%Y/%m/%d (%a)",
								pattern = "^(%d%d%d%d)/(%d%d)/(%d%d).*$",
								order = { 1, 2, 3 },
							},
						},
					},
				},
			},
		})
	end,
}
