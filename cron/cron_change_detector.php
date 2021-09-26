<?php
/**
 * Created by PhpStorm.
 * User: daustria
 * Date: 19/9/21
 * Time: 11:38
 */

namespace daustria\change_detector\cron;

include_once 'tests/daustria/change_detector/lib/composer_manager.php';

use daustria\change_detector\lib\composer_manager;

class cron_change_detector
{
    const LOCAL_PATH = 'test/example/repositories/';
    const TESTING_LIBRARY_CHANGED = 'library_1';

    public function __construct()
    {
    }

    public function run()
    {
        print_r("Scanning path '". self::LOCAL_PATH . "'...\n");
        $directories = composer_manager::get_directories(self::LOCAL_PATH);
        print_r("Directories detected: " . json_encode($directories) . "\n");

        print_r("Generating dependency trees...\n");
        $dependencies = [];
        foreach ($directories as $directory) {
            $dependencies[$directory] = composer_manager::generate_dependency_tree(self::LOCAL_PATH, $directory);
        }

        print_r("Looking for changes in dependent libraries...\n");
        $changes_detected = [];
        foreach ($dependencies as $project => $dependency) {
            if (composer_manager::detect_changes_in_dependent_libraries(self::LOCAL_PATH, $dependency, self::TESTING_LIBRARY_CHANGED)) {
                array_push($changes_detected, $project);
            }
        }

        if ($changes_detected) {
            print_r("Changes detected in dependencies of " . json_encode($changes_detected) . "\n");
            $affected_projects = composer_manager::get_affected_projects($changes_detected, $dependencies);
            foreach ($affected_projects as $project) {
                print_r("Launch {$project} pipeline!\n");
            }
        } else {
            print_r("No changes detected!\n");
        }
    }

}

(new cron_change_detector())->run();