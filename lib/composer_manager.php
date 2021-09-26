<?php
/**
 * Created by PhpStorm.
 * User: daustria
 * Date: 19/9/21
 * Time: 13:20
 */

namespace daustria\change_detector\lib;

class composer_manager
{
    const IN_HOUSE_REPO_PATH = 'ddeaustria';

    const TYPE_PROJECT = 'project';
    const TYPE_LIBRARY = 'library';
    const TYPE_OTHER = 'other';

    private static $directories_by_path = [];

    public static function get_directories(string $path): array
    {
        return self::$directories_by_path[md5($path)] ?? self::get_directories_by_path($path);
    }

    public static function generate_dependency_tree(string $projects_path, string $project): array
    {
        $dependency_tree = [];

        $composer_json_content = json_decode(file_get_contents($projects_path . $project . '/composer.json'), true);

        switch ($composer_json_content['type']) {

            case self::TYPE_PROJECT:
                $dependency_tree['name'] = $composer_json_content['name'];
                $dependency_tree['type'] = self::TYPE_PROJECT;
                $dependency_tree['dependencies'] = !empty($composer_json_content['repositories']) ? self::get_dependent_in_house_libraries($composer_json_content['repositories']) : [];
                break;

            case self::TYPE_LIBRARY:
                $dependency_tree['name'] = $composer_json_content['name'];
                $dependency_tree['type'] = self::TYPE_LIBRARY;
                $dependency_tree['dependencies'] = !empty($composer_json_content['repositories']) ? self::get_dependent_in_house_libraries($composer_json_content['repositories']) : [];
                break;

            default:
                $dependency_tree['name'] = $composer_json_content['name'];
                $dependency_tree['type'] = self::TYPE_OTHER;
                $dependency_tree['dependencies'] = !empty($composer_json_content['repositories']) ? self::get_dependent_in_house_libraries($composer_json_content['repositories']) : [];
        }

        return $dependency_tree;
    }

    public static function detect_changes_in_dependent_libraries(string $projects_path, array $project, string $test_library_changed = ''): bool
    {
        if (!empty($project['dependencies'])) {
            foreach ($project['dependencies'] as $dependency) {
                $lib_name = self::get_project_of_composer_name($dependency['name']);
                $buffer = shell_exec("cd " . $projects_path . $lib_name . "; composer update --dry-run 2>&1");
                if (strpos($buffer, "Nothing to") === false || $lib_name == $test_library_changed) {
                    return true;
                }
            }
        }

        return false;
    }

    public static function get_affected_projects(array $modified_libs, array $directories): array
    {
        $affected_projects = [];
        foreach ($directories as $project => $directory) {
            if ($directory['type'] == self::TYPE_PROJECT) {
                if (in_array($project, $modified_libs)) {
                    array_push($affected_projects, $project);
                }
                if (!empty($directory['dependencies'])) {
                    foreach ($directory['dependencies'] as $dependency) {
                        if (in_array(self::get_project_of_composer_name($dependency['name']), $modified_libs)) {
                            array_push($affected_projects, $project);
                        }
                    }
                }
            }
        }

        return $affected_projects;
    }


    private static function get_directories_by_path(string $path): array
    {
        $directories = [];
        if (is_dir($path)) {
            foreach (array_values(array_diff(scandir($path), ['..', '.'])) as $file) {
                if (is_dir($path . $file)) {
                    array_push($directories, $file);
                }
            }
        }

        return self::$directories_by_path[md5($path)] = $directories;
    }

    private static function get_dependent_in_house_libraries(array $repositories): array
    {
        $dependent_libraries = [];
        foreach ($repositories as $repository) {
            if ($repository['type'] == 'package') {
                $repo_path = $repository['package']['source']['url'] ?? '';
                if (strpos($repo_path, self::IN_HOUSE_REPO_PATH) !== false) {
                    $in_house_lib_detected = [
                        'name' => $repository['package']['name'],
                        'repo_path' => $repo_path,
                    ];
                    array_push($dependent_libraries, $in_house_lib_detected);
                }
            }
        }

        return $dependent_libraries;
    }

    private static function get_project_of_composer_name($composer_name) {
        return explode('/', $composer_name)[1];
    }

}