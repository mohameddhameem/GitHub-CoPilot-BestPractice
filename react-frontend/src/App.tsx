import React from 'react';

function App() {
    return (
        <div className="App">
            <header className="App-header" style={{ padding: '20px', textAlign: 'center' }}>
                <h1>Multi-Stack Starter Kit</h1>
                <p>
                    React Frontend Dashboard
                </p>
                <div style={{ marginTop: '20px', display: 'flex', gap: '10px', justifyContent: 'center' }}>
                    <div style={{ border: '1px solid #ccc', padding: '10px', borderRadius: '8px' }}>
                        <h3>FastAPI Backend</h3>
                        <p>Status: <span style={{ color: 'green' }}>Online (mock)</span></p>
                    </div>
                    <div style={{ border: '1px solid #ccc', padding: '10px', borderRadius: '8px' }}>
                        <h3>PyTorch AI Backend</h3>
                        <p>Status: <span style={{ color: 'green' }}>Online (mock)</span></p>
                    </div>
                </div>
            </header>
        </div>
    );
}

export default App;
