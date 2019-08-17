#define DOCTEST_CONFIG_IMPLEMENTATION_IN_DLL
#include "../../external/doctest/doctest.h"
#include "../NVConv2d.cuh"
#include "../Tensor.cuh"
#include "../Utils.cuh"
#include <iostream>

using namespace std;

TEST_CASE("Utils test") {

  {
    Tensor K0 = random_fill({ 16, 6 });
    Tensor K1 = random_fill({ 16, 6 });
    Tensor K2 = random_fill({ 3, 6 });
    Tensor K3 = random_fill({ 3, 6 });
    Tensor U  = random_fill({ 1, 16, 32, 32 });
    for (int i = 0; i < U.size(); ++i) REQUIRE(U.m_data[i] > 0);

    Tensor K = cp4recom(K0, K1, K2, K3);
    CHECK(K.size() == 2304);
    CHECK(K.order() == 4);
    CHECK(K.shape[0] == 16);
    CHECK(K.shape[1] == 16);
    CHECK(K.shape[2] == 3);
    CHECK(K.shape[3] == 3);

    auto V = NV::Conv2dForward(U, K, 1);
    CHECK(V.size() == (1 * 16 * 32 * 32));
    CHECK(V.order() == 4);
    CHECK(V.shape[0] == 1);
    CHECK(V.shape[1] == 16);
    CHECK(V.shape[2] == 32);
    CHECK(V.shape[3] == 32);
    for (int i = 0; i < V.size(); ++i) REQUIRE(V.m_data[i] != 0);

    auto V2 = NV::Conv2dForward(U, K, 1);
    for (int i = 0; i < V.size(); ++i)
      REQUIRE(V.m_data[i] == doctest::Approx(V2.m_data[i]).epsilon(1e-5));

    REQUIRE(AllClose(V, V2, 1e-5));
    V.m_data[0] *= 2;
    REQUIRE(V.m_data[0] != doctest::Approx(V2.m_data[0]).epsilon(1e-1));
    REQUIRE(!AllClose(V, V2, 1e-1));
  }
}
