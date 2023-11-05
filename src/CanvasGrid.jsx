import React, { useRef, useEffect } from 'react';

const CanvasGrid = ({ agents, signals, size = 64, cellSize = 10 }) => {
  const canvasRef = useRef(null);

  const drawGrid = (ctx) => {
    ctx.strokeStyle = '#333'; // Subtle grid lines
    for (let x = 0; x < size; x++) {
      for (let y = 0; y < size; y++) {
        ctx.strokeRect(x * cellSize, y * cellSize, cellSize, cellSize);
      }
    }
  };

  const drawAgents = (ctx) => {
    ctx.fillStyle = '#FFEB3B'; // Bright color for agents as small dots
    agents.forEach((agent) => {
      ctx.beginPath();
      ctx.arc(
        agent.x * cellSize + cellSize / 2,
        agent.y * cellSize + cellSize / 2,
        cellSize / 4, // Agents are quarter the size of the cell
        0,
        Math.PI * 2
      );
      ctx.fill();
    });
  };

  const drawSignals = (ctx) => {
    ctx.strokeStyle = '#FF1744'; // Bright red for signal outline
    signals.forEach((signal) => {
      ctx.beginPath();
      ctx.arc(
        signal.x * cellSize + cellSize / 2,
        signal.y * cellSize + cellSize / 2,
        signal.radius * cellSize,
        0,
        Math.PI * 2
      );
      ctx.stroke();
    });
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');
    canvas.style.background = '#000'; // Set background color to black

    // Clear the canvas
    context.clearRect(0, 0, canvas.width, canvas.height);

    // Draw the grid, agents, and signals
    drawGrid(context);
    drawAgents(context);
    drawSignals(context);
  }, [agents, signals]); // Redraw when agents or signals state changes

  return (
    <canvas
      ref={canvasRef}
      width={size * cellSize}
      height={size * cellSize}
      style={{ background: 'black', display: 'block', margin: '0 auto' }}
    />
  );
};

export default CanvasGrid;
