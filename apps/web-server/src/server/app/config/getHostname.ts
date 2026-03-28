import TrustedServerAddressPolicy from './TrustedServerAddressPolicy';

function getHostName() {
  return new TrustedServerAddressPolicy({ serverPort: 3000 }).getPreferredServerHost();
}

export default getHostName;
