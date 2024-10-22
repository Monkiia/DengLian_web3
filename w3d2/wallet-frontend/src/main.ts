import { createAppKit } from '@reown/appkit';
import { mainnet, arbitrum } from '@reown/appkit/networks';
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi';

// 1. Get a project ID at https://cloud.reown.com
const projectId = '9390e2ec7af2cf0f90e7ac5e41918115';

// 2. Set up Wagmi adapter
const wagmiAdapter = new WagmiAdapter({
    projectId,
    networks: [mainnet, arbitrum],
});

// 3. Configure the metadata
const metadata = {
    name: 'denglian_s4_oct22',
    description: 'AppKit Example',
    url: 'https://reown.com/appkit',
    icons: ['https://assets.reown.com/reown-profile-pic.png'],
};

// 4. Create the modal
const modal = createAppKit({
    adapters: [wagmiAdapter],
    networks: [mainnet, arbitrum],
    metadata,
    projectId,
    features: {
        analytics: true,
    },
});

// 5. Trigger modal programmatically
const openConnectModalBtn = document.getElementById('open-connect-modal');
const openNetworkModalBtn = document.getElementById('open-network-modal');

if (openConnectModalBtn) {
    openConnectModalBtn.addEventListener('click', () => modal.open());
} else {
    console.error("Connect modal button not found");
}

if (openNetworkModalBtn) {
    openNetworkModalBtn.addEventListener('click', () => modal.open({ view: 'Networks' }));
} else {
    console.error("Network modal button not found");
}
