# https://en.wikipedia.org/wiki/Eulerian_path#Fleury's_algorithm
# https://encyclopediaofmath.org/wiki/Euler_tour

# Neelam Yadav:
# https://www.geeksforgeeks.org/fleurys-algorithm-for-printing-eulerian-path/

# https://www.ics.uci.edu/~eppstein/163/lecture5a.pdf

from board import Board


class Graph:
    def __init__(self,
                 edges,
                 /,
                 vertices=None,
                 board=None,
                 interactive=False):
        self.vertices = vertices
        self.board = board
        self.interactive = interactive
        self.G = {}
        [self.add_edge(*edge) for edge in edges]
        self.G = {k: list(set(v)) for k, v in self.G.items()}

    def add_edge(self, src, dst, idxs=None):
        u_idx, v_idx = (idxs or [None, None])
        self.G.setdefault(src, [])
        gs = self.G[src]
        gs.insert(u_idx, dst) if u_idx is not None else gs.append(dst)

        self.G.setdefault(dst, [])
        ds = self.G[dst]
        ds.insert(v_idx, src) if v_idx is not None else ds.append(src)

    def remove_edge(self, v, u):
        u_idx = self.G[v].index(u)
        self.G[v].pop(u_idx)

        v_idx = self.G[u].index(v)
        self.G[u].pop(v_idx)

        return [u_idx, v_idx]

    def get_odd_degree_vertices(self):
        return {s: len(d) for s, d in self.G.items() if len(d) % 2 != 0}

    def get_pathlen(self, src, limit=None, visited=None):
        """Recursive"""
        visited = (visited or {})
        visited[src] = 1
        if limit is not None and len(visited) > limit:
            return len(visited)
        for adjacent in self.G[src]:
            if adjacent not in visited:
                self.get_pathlen(adjacent, limit, visited)
        return len(visited)

    def is_edge_valid(self, v, u):
        if len(self.G[v]) == 1:
            return True

        vlen = self.get_pathlen(v)
        [u_idx, v_idx] = self.remove_edge(v, u)
        ulen = self.get_pathlen(u, vlen + 1)
        self.add_edge(v, u, [u_idx, v_idx])

        # Tricky:
        return vlen <= ulen

    def traverse(self, v, paths):
        """Recursive"""
        # visualization
        if isinstance(self.board, Board):
            assert v in self.vertices, "Missing: " + v
            r, c = self.vertices[v]
            self.board.set_field(r, c, self.board.C.BLUE, v)
            self.board.redraw(True)
        # --------------------------

        for u in self.G[v]:
            if self.is_edge_valid(v, u):
                path = [v, u]
                back = [u, v]
                assert path not in paths, "Does not traverse twice"
                assert back not in paths, "Does not traverse twice"
                paths.append(path)

                self.board.draw_edge(v, u, self.board.C.RED, True)
                if self.interactive:
                    print("EDGE", v, u)
                    print("Traversed edges:", ["-".join(p) for p in paths])
                    input("[Enter]")
                self.remove_edge(v, u)
                self.traverse(u, paths)

    def find_eulerian_path(self):
        self.board.redraw()
        odd_vertices = self.get_odd_degree_vertices()
        n_odd = len(odd_vertices)
        assert n_odd in [0, 2], "0 or 2 odd vertices"
        nodes = odd_vertices if n_odd else self.G
        assert nodes, "Has somewhere to start"
        v = sorted(nodes.items(), key=lambda p: -p[1])[0][0]
        traversed_paths = []
        self.traverse(v, traversed_paths)
        return traversed_paths


if __name__ == "__main__":
    import argparse
    import json
    import os

    DEFAULT_DATASET = os.path.join(
        os.path.dirname(__file__),
        "data",
        "envelope.json",
    )

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interactive", action="store_true")
    parser.add_argument("file", type=str, nargs="?",
                        default=DEFAULT_DATASET)

    args = parser.parse_args()

    with open(args.file, "r") as fh:
        data = json.load(fh)

    board = Board(*data["board"]["size"])

    # Place vertices on the board
    for v_name, v_coord in data["vertices"].items():
        board.set_field(*v_coord, board.C.GRAY, v_name, field_id=v_name)
    board.redraw()

    # Draw all edges
    [board.draw_edge(*edge, board.C.GREEN) for edge in data["edges"]]

    board.redraw()

    input("Ready? ") if args.interactive else ...

    G = Graph(
        data["edges"],
        vertices=data["vertices"],
        board=board,
        interactive=args.interactive,
    )
    path = G.find_eulerian_path()
    print("Eulerian path:", path)
    print("Path length:", len(path))
