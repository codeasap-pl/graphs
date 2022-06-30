def smp(A, B):
    A_unpaired = list(A.keys())
    pairs = {}

    while A_unpaired:
        a = A_unpaired.pop(0)
        A_preferences = A[a]
        b = A_preferences.pop(0)  # is processed
        edge = pairs.get(b)  # is connected
        if not edge:
            pairs[b] = a
        else:
            B_preferences = B[b]  # B where src = b
            index_old = B_preferences.index(edge)
            index_new = B_preferences.index(a)
            if index_new < index_old:
                pairs[b] = a
                if len(A[edge]):  # has more preferences
                    A_unpaired.append(edge)
            else:
                if A_preferences:
                    A_unpaired.append(a)
    return pairs


def example_1():
    A = {
        1: [2, 1, 3, 4],
        2: [4, 1, 2, 3],
        3: [1, 3, 2, 4],
        4: [2, 3, 1, 4],
    }

    B = {
        1: [1, 3, 2, 4],
        2: [3, 4, 1, 2],
        3: [4, 2, 3, 1],
        4: [3, 2, 1, 4],
    }

    pairs = smp(A, B)
    edges = {v: u for (u, v) in sorted(pairs.items())}
    assert edges == {1: 1, 2: 4, 3: 3, 4: 2}
    print(edges)


def example_2():
    from data import A_names, B_names, A, B
    import pprint

    pairs = smp(A, B)
    edges = {v: u for (u, v) in sorted(pairs.items())}

    A = {i: n for i, n in enumerate(A_names.keys(), 1)}
    B = {i: n for i, n in enumerate(B_names.keys(), 1)}

    expected = {
        "abi": "jon",
        "bea": "fred",
        "cath": "bob",
        "dee": "col",
        "eve": "hal",
        "fay": "dan",
        "gay": "gav",
        "hope": "ian",
        "ivy": "abe",
        "jan": "ed",
    }
    got = {A[k]: B[v] for k, v in edges.items()}
    for ek, ev in expected.items():
        assert got[ek] == ev, "%s (got %s, expected: %s)"  % (ek, got[ek], ev)
    pprint.pprint(got)
    pprint.pprint(edges)


if __name__ == "__main__":
    example_1()
    example_2()
