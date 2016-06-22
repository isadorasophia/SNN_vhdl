#include <iostream>
#include <bitset>

#include <cmath>
#include <stdint.h>

#define MIN_UNIT 0.03125

int main()
{
    double max = 127.99609375, // max value of 8 bits precision
           min = -128,         // min value
           cur, t, result;

    float i_to_bin, // input
          o_to_bin; // output

    int s;

    std::string binary_i, binary_o;

    cur = max;

    while (cur > min) {
        result = 1/(1 + pow(exp(1), -cur));

        result = result * (1 - result);

        if (cur < 0) {
            s = 1;
            t = std::abs(cur) - MIN_UNIT;
        } else {
            s = 0;
            t = cur;
        }

        i_to_bin = t * pow(2, 8);
        o_to_bin = result * pow(2, 8);

        binary_i = std::bitset<15>(i_to_bin).to_string(); // to binary
        binary_o = std::bitset<15>(o_to_bin).to_string(); // to binary

        binary_i.resize(12);
        // binary_o.resize(15);

        // when else
        std::cout << "\"0" << binary_o << "\" when t_in(i'length - 1 downto 3) = \"";
        std::cout << s << binary_i << "\" else\n";

        // case        
        // std::cout << "when \"" << s << binary_i << "\" => t_o <= \"";
        // std::cout << "0" << binary_o << "\";" << "\n";

        cur -= MIN_UNIT;
    }
    
    return 0;
}

