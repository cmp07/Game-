# Game-

A small browser **Snake** game built with [Vite](https://vitejs.dev/), TypeScript, and an HTML5 canvas.

## Getting started

```bash
npm ci        # install dependencies (or `npm install` for a fresh clone)
npm run dev   # start the Vite dev server at http://localhost:5173
```

## Available scripts

| Script            | Description                                        |
| ----------------- | -------------------------------------------------- |
| `npm run dev`     | Start the Vite dev server with hot reloading.      |
| `npm run build`   | Type-check and build a production bundle to `dist`.|
| `npm run preview` | Serve the production build locally.                |
| `npm run typecheck` | Run the TypeScript compiler with no emit.        |

## How to play

- Steer with the **arrow keys** or **WASD**.
- Eat the pink food to grow and score points.
- Press **Space** to start, pause, and resume.
- Avoid the walls and your own tail.

## Cloud Agent environment

`.cursor/environment.json` configures the Cursor Cloud Agent environment: it runs
`npm ci` to install dependencies and launches the Vite dev server on port `5173`
in a persistent terminal.
