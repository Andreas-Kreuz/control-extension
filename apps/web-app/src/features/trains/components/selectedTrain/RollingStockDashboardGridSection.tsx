import { RollingStockAppDto } from '@ce/web-shared';
import useRollingStockDashboardGrid from '../../hooks/useRollingStockDashboardGrid';
import RollingStockDashboardGrid, { RollingStockDashboardCard } from '../panels/RollingStockDashboardGrid';

function RollingStockDashboardGridSection(props: {
  rollingStock: RollingStockAppDto[];
  selectedRollingStockName: string;
}) {
  if (props.rollingStock.length === 0) {
    return <RollingStockDashboardGrid cards={[]} />;
  }

  return (
    <>
      {props.rollingStock.map((item, index) => (
        <RollingStockDashboardCardSection
          key={item.id}
          position={index + 1}
          rollingStock={item}
          selected={props.selectedRollingStockName === item.id || props.selectedRollingStockName === item.name}
          total={props.rollingStock.length}
        />
      ))}
    </>
  );
}

function RollingStockDashboardCardSection(props: {
  position: number;
  rollingStock: RollingStockAppDto;
  selected: boolean;
  total: number;
}) {
  const card: RollingStockDashboardCard = useRollingStockDashboardGrid(
    props.rollingStock,
    props.position,
    props.selected,
    props.total,
  );

  return <RollingStockDashboardGrid cards={[card]} />;
}

export default RollingStockDashboardGridSection;
