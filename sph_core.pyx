import numpy as np
cimport numpy as np
from scipy.special import gamma
from libc.math cimport sqrt, exp, pow, M_PI


import numpy as np
cimport numpy as np
from scipy.special import gamma
from libc.math cimport sqrt, exp, pow, M_PI

cdef inline double W_cython(double dx, double dy, double dz, double h) nogil:
    cdef double r2 = dx*dx + dy*dy + dz*dz
    # Använder C:s exp och sqrt istället för NumPys
    return (1.0 / (h * sqrt(M_PI)))**3 * exp(-r2 / (h*h))

cdef void getDensity_cython(double[:, :] pos, double m, double h, double[:] rho) nogil:
    cdef int N = pos.shape[0]
    cdef int i, j
    cdef double dx, dy, dz

    for i in range(N):
        rho[i] = 0.0
        for j in range(N):
            dx = pos[i, 0] - pos[j, 0]
            dy = pos[i, 1] - pos[j, 1]
            dz = pos[i, 2] - pos[j, 2]
            rho[i] += m * W_cython(dx, dy, dz, h)

cdef void getAcc_cython(double[:, :] pos, double[:, :] vel, double m, double h, double k, double n_poly, double lmbda, double nu, double[:] rho, double[:] P, double[:, :] acc) nogil:
    cdef int N = pos.shape[0]
    cdef int i, j
    cdef double dx, dy, dz, r2, n_val, wx, wy, wz, pressure_term

    getDensity_cython(pos, m, h, rho)

    for i in range(N):
        P[i] = k * pow(rho[i], 1.0 + 1.0/n_poly)

    for i in range(N):
        acc[i, 0] = 0.0
        acc[i, 1] = 0.0
        acc[i, 2] = 0.0

        for j in range(N):
            dx = pos[i, 0] - pos[j, 0]
            dy = pos[i, 1] - pos[j, 1]
            dz = pos[i, 2] - pos[j, 2]

            r2 = dx*dx + dy*dy + dz*dz
            n_val = -2.0 * exp(-r2 / (h*h)) / (pow(h, 5) * pow(M_PI, 1.5))
            wx = n_val * dx
            wy = n_val * dy
            wz = n_val * dz

            pressure_term = (P[i] / (rho[i]*rho[i])) + (P[j] / (rho[j]*rho[j]))

            acc[i, 0] -= m * pressure_term * wx
            acc[i, 1] -= m * pressure_term * wy
            acc[i, 2] -= m * pressure_term * wz

        acc[i, 0] += -lmbda * pos[i, 0] - nu * vel[i, 0]
        acc[i, 1] += -lmbda * pos[i, 1] - nu * vel[i, 1]
        acc[i, 2] += -lmbda * pos[i, 2] - nu * vel[i, 2]
def run_sph_cython(int N=400):
    cdef double t = 0.0
    cdef double tEnd = 12.0
    cdef double dt = 0.04
    cdef double M = 2.0
    cdef double R = 0.75
    cdef double h = 0.1
    cdef double k = 0.1
    cdef double n_poly = 1.0
    cdef double nu = 1.0

    np.random.seed(42)

    cdef double lmbda = (2 * k * (1 + n_poly) * np.pi ** (-3 / (2 * n_poly)) * (M * gamma(5 / 2 + n_poly) / R**3 / gamma(1 + n_poly)) ** (1 / n_poly) / R**2)
    cdef double m = M / N

    pos_np = np.random.randn(N, 3).astype(np.float64)
    vel_np = np.zeros((N, 3), dtype=np.float64)
    acc_np = np.zeros((N, 3), dtype=np.float64)
    rho_np = np.zeros(N, dtype=np.float64)
    P_np = np.zeros(N, dtype=np.float64)

    cdef double[:, :] pos = pos_np
    cdef double[:, :] vel = vel_np
    cdef double[:, :] acc = acc_np
    cdef double[:] rho = rho_np
    cdef double[:] P = P_np

    cdef int Nt = int(np.ceil(tEnd / dt))
    cdef int i, step

    getAcc_cython(pos, vel, m, h, k, n_poly, lmbda, nu, rho, P, acc)

    for step in range(Nt):
        for i in range(N):
            vel[i, 0] += acc[i, 0] * dt / 2.0
            vel[i, 1] += acc[i, 1] * dt / 2.0
            vel[i, 2] += acc[i, 2] * dt / 2.0

        for i in range(N):
            pos[i, 0] += vel[i, 0] * dt
            pos[i, 1] += vel[i, 1] * dt
            pos[i, 2] += vel[i, 2] * dt

        getAcc_cython(pos, vel, m, h, k, n_poly, lmbda, nu, rho, P, acc)

        for i in range(N):
            vel[i, 0] += acc[i, 0] * dt / 2.0
            vel[i, 1] += acc[i, 1] * dt / 2.0
            vel[i, 2] += acc[i, 2] * dt / 2.0

        t += dt

    return pos_np, vel_np
