
def define_env(env):
    variables = {'HELLO_WORLD_INCLUDE': '```cpp\n#include <robot_dart/robot_dart_simu.hpp>\n\n#ifdef GRAPHIC\n#include <robot_dart/gui/magnum/graphics.hpp>\n#endif\n```', 'HELLO_WORLD_ROBOT_CREATION': '```cpp\nauto robot = std::make_shared<robot_dart::Robot>("pexod.urdf");\n```', 'HELLO_WORLD_ROBOT_PLACING': '```cpp\nrobot->set_base_pose(robot_dart::make_tf({0., 0., 0.2}));\n```', 'HELLO_WORLD_ROBOT_SIMU': '```cpp\nrobot_dart::RobotDARTSimu simu(0.001); // dt=0.001, 1KHz simulation\nsimu.add_floor();\nsimu.add_robot(robot);\n```', 'HELLO_WORLD_ROBOT_GRAPHIC': '```cpp\n#ifdef GRAPHIC\n    auto graphics = std::make_shared<robot_dart::gui::magnum::Graphics>();\n    simu.set_graphics(graphics);\n    graphics->look_at({0.5, 3., 0.75}, {0.5, 0., 0.2});\n#endif\n```', 'HELLO_WORLD_ROBOT_RUN': '```cpp\nsimu.run(10.);\n```', 'ROBOT_POOL_INCLUDE': '```cpp\n#include <robot_dart/robot_pool.hpp>\n```', 'ROBOT_POOL_GLOBAL_NAMESPACE': '```cpp\nnamespace pool {\n    // This function should load one robot: here we load Talos\n    std::shared_ptr<robot_dart::Robot> robot_creator()\n    {\n        std::vector<std::pair<std::string, std::string>> packages = {{"talos_description", "talos/talos_description"}};\n        return std::make_shared<robot_dart::Robot>("talos/talos.urdf", packages);\n    }\n\n    // To create the object we need to pass the robot_creator function and the number of maximum parallel threads\n    robot_dart::RobotPool robot_pool(robot_creator, NUM_THREADS);\n} // namespace pool\n```', 'ROBOT_POOL_EVAL': '```cpp\nvoid eval_robot(int i)\n{\n    // We get one available robot\n    auto robot = pool::robot_pool.get_robot();\n    std::cout << "Robot " << i << " got [" << robot->skeleton() << "]" << std::endl;\n\n    /// --- some robot_dart code ---\n    simulate_robot(robot);\n    // --- do something with the result\n\n    std::cout << "End of simulation " << i << std::endl;\n\n    // CRITICAL : free your robot !\n    pool::robot_pool.free_robot(robot);\n\n    std::cout << "Robot " << i << " freed!" << std::endl;\n}\n```', 'ROBOT_POOL_CREATE_THREADS': '```cpp\n// for the example, we run NUM_THREADS threads of eval_robot()\nstd::vector<std::thread> threads(NUM_THREADS * 2); // *2 to see some reuse\nfor (size_t i = 0; i < threads.size(); ++i)\n    threads[i] = std::thread(eval_robot, i); // eval_robot is the function that uses the robot\n```', 'RECORD_VIDEO_ROBOT_GRAPHICS_PARAMS': '```cpp\nrobot_dart::gui::magnum::GraphicsConfiguration configuration;\nconfiguration.width = 1280;\nconfiguration.height = 960;\nconfiguration.bg_color = Eigen::Vector4d{1.0, 1.0, 1.0, 1.0};\nauto graphics = std::make_shared<robot_dart::gui::magnum::Graphics>(configuration);\nsimu.set_graphics(graphics);\ngraphics->look_at({0., 3.5, 2.}, {0., 0., 0.25});\ngraphics->record_video("talos_dancing.mp4");\n```'}
    for v in variables.items():
        env.variables[v[0]] = variables[v[0]]
