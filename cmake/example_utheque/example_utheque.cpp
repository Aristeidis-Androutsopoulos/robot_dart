#include <iostream>
#include <utheque/utheque.hpp>

int main()
{
    auto p = utheque::path("talos/talos.urdf", true); // verbose mode
    std::cout << "Path of the URDF: " << p << std::endl;
    return 0;
}
