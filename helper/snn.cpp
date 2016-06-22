#include <stdio.h>
#include <cmath>

#include <stdlib.h>
#include <string.h>

#define IN_S  4
#define HID_S 4
#define OUT_S 1

/** IT WORKS!!! <3333 **/
/* Implementação de rede neural em C */

float sigmoid(float x) {
    return 1.0/(1 + pow(exp(1), -x));
}

float neuron(float w[], float w_s, float a[], float* z = NULL) {
    int i = 0;
    float result = 0;

    for (i = 0; i < w_s; i++) {
        result += w[i] * a[i];
    }

    if (z != NULL) {
        *z = result;
    }

    result = sigmoid(result);

    return result;
}

// estimate new weight
void new_weight(float delta, float lambda, float* old_w) {
    *old_w -= lambda * delta;
}

float lower_delta_h(float w[], float d[], int output_size, float z) {
    float result = 0;

    for (int i = 0; i < output_size; i++) {
        result += w[i] * d[i];
    }

    // derivative
    z = sigmoid(z);
    z = z * (1 - z);

    result *= z;

    return result;
}

float lower_delta_o(float a, float y) {
    return a - y;
}

float upper_delta(float a, float delta) {
    // a is the activation value
    return a * delta;
}

int main () {
    /* Theta1 */
    float Theta1[(IN_S + 1) * HID_S],
          Theta2[(HID_S + 1) * OUT_S];

    // include bias
    float inputs[16 * (IN_S + 1)] = {1, 0, 1, 0, 0,
                                    1, 1, 0, 0, 0,
                                    1, 0, 0, 0, 0,
                                    1, 1, 1, 0, 0,
                                    1, 0, 1, 0, 1,
                                    1, 1, 0, 0, 1,
                                    1, 0, 0, 0, 1,
                                    1, 1, 1, 0, 1,
                                    1, 0, 1, 1, 0,
                                    1, 1, 0, 1, 0,
                                    1, 0, 0, 1, 0,
                                    1, 1, 1, 1, 0,
                                    1, 0, 1, 1, 1,
                                    1, 1, 0, 1, 1,
                                    1, 0, 0, 1, 1,
                                    1, 1, 1, 1, 1};
    float output[16] = {1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1};

    // deltinha
    float d_2[HID_S], d_3[OUT_S];

    // deltao
    float D_1[(IN_S + 1) * HID_S], D_2[(HID_S + 1) * OUT_S];

    // a2 := BIAS + NEURONIOS
    // a3 := NEURONIOS DE SAIDA
    float a2[HID_S + 1], a3[OUT_S];

    // guarda z da hidden layer (no bias needed)
    float z[HID_S];

    float lambda = 0.5;
    int i = 0, cur_input = 0;

    float loss = 0;

    printf("Theta1: \n");

    /* Randomize weights */
    for (int i=0; i<IN_S+1; i++) {
        for (int j=0; j<HID_S; j++) {
            Theta1[i * HID_S + j] = ((float)rand() / (double)RAND_MAX) * 1;
            printf("%f", Theta1[i * HID_S + j]);
        }

        printf("\n");
    }

    printf("Theta2: \n");

    for (int i=0; i<HID_S+1; i++) {
        for (int j=0; j<OUT_S; j++) {
            Theta2[i * OUT_S + j] = ((float)rand() / (double)RAND_MAX) * 1;
            printf("%f", Theta2[i * OUT_S + j]);
        }

        printf("\n");
    }

    /* ----------- */
    /* Training */
    for (int k = 0; k < 1000; k++) {
        // printf("/* *** Training set: \t%d *** */\n", k);

        for (cur_input = 0; cur_input < 16; cur_input++) {
            /* --- Feedforward --- */
            for (int i = 0; i < HID_S; i++) {
                float m_w[IN_S + 1];
                float m_a[IN_S + 1];

                /* get weights */
                for (int j = 0; j < IN_S + 1; j++) {
                    // theta1[j][i]
                    //   each neuron is a column
                    m_w[j] = Theta1[j * HID_S + i];
                }

                /* Initialize input */
                for (int j = 0; j < IN_S + 1; j++) {
                    // m_a[j] := inputs[cur_input][j]
                    m_a[j] = inputs[cur_input * (IN_S + 1) + j];
                }

                // get activation value from each neuron
                a2[i + 1] = neuron(m_w, IN_S + 1, m_a, &z[i]);
            }

            a2[0] = 1; // add bias!

            for (int i = 0; i < OUT_S; i++) {
                float m_w[HID_S + 1];

                /* get weights */
                for (int j = 0; j < HID_S + 1; j++) {
                    // theta[j][i]
                    //   each neuron is a column
                    m_w[j] = Theta2[j * OUT_S + i];
                }

                a3[i] = neuron(m_w, HID_S + 1, a2);
            }

            /* --- Backpropagation --- */
            /* lower delta output */
            for (int i = 0; i < OUT_S; i++) {
                d_3[i] = lower_delta_o(a3[i], output[cur_input]);

                // printf("Lower delta output: \t%f\n", d_3[i]);
            }

            /* lower delta hidden */
            /* --- Hidden -> Output --- */
            /*       for each weight line i */
            for (int i = 1; i < HID_S + 1; i++) {
                for (int j = 0; j < OUT_S; j++) {
                    d_2[i - 1] = lower_delta_h(&Theta2[i * OUT_S + j], &d_3[j], OUT_S, z[i - 1]);

                    // printf("Lower delta 2_%d: \t%f\n", i, d_2[i - 1]);
                }
            }

            // printf("\n/* *** hidden -> output *** */\n");

            /* upper delta 2! */
            /* Hidden -> Output */
            for (int i = 0; i < HID_S + 1; i++) {
                for (int j = 0; j < OUT_S; j++) {
                    D_2[i * OUT_S + j] = upper_delta(a2[i], d_3[j]);

                    new_weight(D_2[i * OUT_S + j], lambda, &Theta2[i * OUT_S + j]);

                    // printf("From weight (%d, %d): \t%f\n", i, j, Theta2[i * OUT_S + j]);
                }
            }

            // printf("\n/* *** input -> hidden *** */\n");

            /* upper delta 1! */
            /* Input -> Hidden */
            for (int i = 0; i < IN_S + 1; i++) {
                for (int j = 0; j < HID_S; j++) {
                    D_1[i * HID_S + j] = upper_delta(inputs[((IN_S + 1) * cur_input) + i], d_2[j]);

                    new_weight(D_1[i * HID_S + j], lambda, &Theta1[i * HID_S + j]);

                    // printf("From weight (%d, %d): \t%f\n", i, j, Theta1[i * HID_S + j]);
                }
            }

            loss -= output[cur_input] * log(a3[0]);
        }
    }

    /* ----------- */
    /* Feedforward */
    for (cur_input = 0; cur_input < 16; cur_input++) {
        printf("/* *** Set no. %d *** */\n", cur_input);
        printf("/* --- Input -> Hidden layer --- */ \n");

        /* --- Feedforward --- */
        a2[0] = 1; // bias

        for (int i = 0; i < HID_S; i++) {
            float m_w[IN_S + 1];
            float m_a[IN_S + 1];

            /* get weights */
            for (int j = 0; j < IN_S + 1; j++) {
                // theta1[j][i]
                //   each neuron is a column
                m_w[j] = Theta1[j * HID_S + i];

                printf("Weight \t%d for neuron \t%d: \t%f\n", j, i, m_w[j]);
            }

            /* Initialize input */
            for (int j = 0; j < IN_S + 1; j++) {
                // m_a[j] := inputs[cur_input][j]
                m_a[j] = inputs[cur_input * (IN_S + 1) + j];

                printf("Input \t%d for neuron \t%d: \t%f\n", j, i, m_a[j]);
            }

            // get activation value from each neuron
            a2[i + 1] = neuron(m_w, IN_S + 1, m_a, &z[i]);

            printf("Output for neuron \t%d: \t%f\n\n", i, a2[i + 1]);
        }

        printf("\n/* --- Hidden -> Output layer --- */ \n");

        for (int i = 0; i < OUT_S; i++) {
            float m_w[HID_S + 1];

            /* get weights */
            for (int j = 0; j < HID_S + 1; j++) {
                // theta[j][i]
                //   each neuron is a column
                m_w[j] = Theta2[j * OUT_S + i];

                printf("Weight \t%d for neuron \t%d: \t%f\n", j, i, m_w[j]);
            }

            a3[i] = neuron(m_w, HID_S + 1, a2);

            printf("Output for neuron \t%d: \t%f\n", i, a3[i]);
        }

        printf("\n/* --- Answer --- */ \n");
        printf("Final output: %d\n\n", a3[0] > 0.5 ? 1 : 0);
    }

    return 0;
}