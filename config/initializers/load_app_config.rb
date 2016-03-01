# Load App defaults from config/app/init_values.yaml

INIT_VALS = YAML.load_file(Rails.root.join('config/app/init_values.yaml'))

EMPLOYEE_DEFAULT_ACCESS_LEVEL = INIT_VALS[:access_levels][-1]