import MyVersionInfo, { VersionInfoProps as MyVersionInfoProps } from '../../../features/statistics/components/VersionInfo';

export type VersionInfoProps = Omit<MyVersionInfoProps, 'children'>;

export const VersionInfo = ({ ...args }: VersionInfoProps) => (
  <div style={{ minHeight: '20rem' }}>
    <MyVersionInfo {...args} />
  </div>
);

export default VersionInfo;
