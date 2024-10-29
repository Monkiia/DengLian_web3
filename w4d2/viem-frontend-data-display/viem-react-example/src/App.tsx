// src/App.tsx
import React, { useEffect, useState } from 'react';
import { createPublicClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { parseAbiItem } from 'viem';

const USDT_ADDRESS = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
const USDT_ABI = parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)');

const App: React.FC = () => {
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    // Use the Vercel environment variable for Infura URL
    const client = createPublicClient({
      chain: sepolia,
      transport: http(`https://eth-mainnet.g.alchemy.com/v2/_T8UEPlogJ0JFhcO5JtjuHPAJCjQfm1v`),
    });

    const addLog = (message: string) => {
      setLogs((prevLogs) => [...prevLogs, message]);
    };

    client.watchBlocks({
      onBlock: (block) => {
        addLog(`New Block - Number: ${block.number}, Hash: ${block.hash}`);
      },
      onError: (error) => {
        addLog(`Error in block listener: ${error.message}`);
      },
    });

    client.watchEvent({
      address: USDT_ADDRESS,
      event: USDT_ABI,
      onLogs: (logs) => {
        logs.forEach((log) => {
          const { from, to, value } = log.args as { from: string; to: string; value: bigint };
          addLog(`USDT Transfer - From: ${from}, To: ${to}, Value: ${value / 10n ** 6n} USDT`);
        });
      },
      onError: (error) => {
        addLog(`Error in USDT transfer listener: ${error.message}`);
      },
    });
  }, []);

  return (
    <div style={{ fontFamily: 'Arial, sans-serif', padding: '20px', maxWidth: '600px', margin: 'auto' }}>
      <h1>Real-Time Ethereum Logs</h1>
      <div style={{ maxHeight: '500px', overflowY: 'auto', backgroundColor: '#f9f9f9', padding: '10px', border: '1px solid #ccc' }}>
        {logs.map((log, index) => (
          <p key={index} style={{ margin: 0, padding: '5px', borderBottom: '1px solid #eee' }}>{log}</p>
        ))}
      </div>
    </div>
  );
};

export default App;
