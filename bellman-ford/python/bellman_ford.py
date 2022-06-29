import math


def initialize(G, s):
    d = {}
    P = {}
    for v in G.vertices:
        d[v] = math.inf
        P[v] = None
    d[s] = 0
    return d, P


def relax(u, v, c, d, P):
    if d[v] > d[u] + c:
        d[v] = d[u] + c
        P[v] = u


def bellman_ford(G, s):
    assert s in G.vertices, "No such vertex: %s" % s
    d, P = initialize(G, s)

    for _ in range(G.size - 1):
        for u, v, c in G.edges:
            relax(u, v, c, d, P)

    return d, P


if __name__ == "__main__":
    """
    D                   P
----------------------------
    0                   0
    1                   2
    2                   4
    3                   2
    4                   7
    """

    """
         1 -(2) - 3
        /       /    \
      (2)     (4)   (-5)
      /       /       |
    0 -(4)-- 2--(3)-- 4
    """

    # class G:
    #     vertices = [0, 1, 2, 3, 4]
    #     size = len([0, 1, 2, 3, 4])
    #     edges = [
    #         (0, 1, 2),
    #         (0, 2, 4),
    #         (1, 3, 2),
    #         (2, 4, 3),
    #         (2, 3, 4),
    #         (4, 3, -5),
    #     ]

    # s = 0
    # d, P = bellman_ford(G, s)

    # for v in G.vertices:
    #     print((s, v), " -> ", ("!" if P[v] is None else P[v]), "Dist:", d[v])

    class G:
        vertices = [0, 1, 2, 3, 4]
        size = len([0, 1, 2, 3, 4])
        edges = [
            (0, 1, 9),
            (0, 2, 3),

            (1, 2, 6),
            (1, 4, 2),

            (2, 1, 2),
            (2, 3, 1),

            (3, 2, 2),
            (3, 4, 2),
        ]

    s = 0
    d, P = bellman_ford(G, s)

    for v in G.vertices:
        print((s, v), " -> ", ("!" if P[v] is None else P[v]), "Dist:", d[v])
