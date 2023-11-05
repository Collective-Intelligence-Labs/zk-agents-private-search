import React from 'react';

const SignalsTable = ({ signals }) => {
  return (
    <div>
      <h3>Signals Table</h3>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>X Position</th>
            <th>Y Position</th>
            <th>Radius</th>
          </tr>
        </thead>
        <tbody>
          {signals.map((signal, index) => (
            <tr key={index}>
              <td>{index + 1}</td>
              <td>{signal.x}</td>
              <td>{signal.y}</td>
              <td>{signal.radius}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default SignalsTable;