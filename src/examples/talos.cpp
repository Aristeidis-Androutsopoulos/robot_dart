#include <robot_dart/robot_dart_simu.hpp>

#ifdef GRAPHIC
#include <robot_dart/gui/magnum/graphics.hpp>
#endif

int main()
{
    std::vector<std::pair<std::string, std::string>> packages = {{"talos_description", "talos/talos_description"}};
    auto robot = std::make_shared<robot_dart::Robot>("talos/talos.urdf", packages);
    std::cout << "The model used is: [" << robot->model_filename() << "]" << std::endl;

    auto positions = robot->positions();
    positions[2] = M_PI / 2.;
    positions[5] = 1.1;
    robot->set_positions(positions);

    // Set actuator types to VELOCITY (for speed)
    robot->set_actuator_types("velocity");
    // Enforce limits (ON by default)
    robot->set_position_enforced(true);

    double dt = 0.001;
    robot_dart::RobotDARTSimu simu(dt);
    simu.set_collision_detector("fcl");
#ifdef GRAPHIC
    // @RECORD_VIDEO_ROBOT_GRAPHICS_PARAMS@
    robot_dart::gui::magnum::GraphicsConfiguration configuration;
    configuration.width = 1280;
    configuration.height = 960;
    configuration.bg_color = Eigen::Vector4d{1.0, 1.0, 1.0, 1.0};
    auto graphics = std::make_shared<robot_dart::gui::magnum::Graphics>(configuration);
    simu.set_graphics(graphics);
    graphics->look_at({0., 3.5, 2.}, {0., 0., 0.25});
    graphics->record_video("talos_dancing.mp4");
    // @RECORD_VIDEO_ROBOT_GRAPHICS_PARAMS_END@
#endif
    simu.add_checkerboard_floor();
    simu.add_robot(robot);

    simu.set_control_freq(100);
    std::vector<std::string> dofs = {"arm_left_1_joint",
        "arm_left_2_joint",
        "arm_right_1_joint",
        "arm_right_2_joint",
        "torso_1_joint"};

    Eigen::VectorXd init_positions = robot->positions(dofs);

    auto start = std::chrono::steady_clock::now();
    while (simu.scheduler().next_time() < 20. && !simu.graphics()->done()) {
        if (simu.schedule(simu.control_freq())) {
            Eigen::VectorXd delta_pos(5);
            delta_pos << sin(simu.scheduler().current_time() * 2.),
                sin(simu.scheduler().current_time() * 2.),
                sin(simu.scheduler().current_time() * 2.),
                sin(simu.scheduler().current_time() * 2.),
                sin(simu.scheduler().current_time() * 2.);
            Eigen::VectorXd commands = (init_positions + delta_pos) - robot->positions(dofs);
            robot->set_commands(commands, dofs);
        }

        simu.step_world();
    }

    auto end = std::chrono::steady_clock::now();
    std::chrono::duration<double> elapsed_seconds = end - start;
    std::cout << "benchmark time: " << elapsed_seconds.count() << "s\n";

    return 0;
}
