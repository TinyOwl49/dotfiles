local venv = os.getenv("CONDA_PREFIX")
local command = string.format("%s/bin/python", venv)

require("dap-python").setup(command)
