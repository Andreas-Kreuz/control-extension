import * as fromJsonData from "../../eep/server-data/EepDataStore";
import { TrainLuaDto } from "../../ce/dto/trains/TrainLuaDto";
import { RollingStockSelector } from "./RollingStockSelector";
import { calcTrainType, TrainDto, TrainListDto, TrainType } from "@ak/web-shared";

export class TrainSelector {
    private state: fromJsonData.State = undefined;
    private trainMap = new Map<string, TrainDto>();
    private trainListMap = new Map<string, TrainListDto>();

    constructor(private rollingStockSelector: RollingStockSelector) {}

    updateFromState = (state: Readonly<fromJsonData.State>): void => {
        if (this.state === state || !state.rooms["trains"]) {
            return;
        }
        this.rollingStockSelector.updateFromState(state);

        this.trainMap.clear();
        this.trainListMap.clear();

        const trainDict = state.rooms["trains"] as unknown as Record<string, TrainLuaDto>;
        Object.values(trainDict).forEach((trainDto: TrainLuaDto) => {
            const rollingStock = this.rollingStockSelector.rollingStockListOfTrain(trainDto.id);
            const trainType: TrainType = this.getTrainType(trainDto);
            const trainListDto: TrainListDto = {
                id: trainDto.id,
                name: trainDto.name,
                route: trainDto.route,
                line: trainDto.line,
                destination: trainDto.destination,
                trainType: trainType,
                trackType: trainDto.trackType,
                rollingStockCount: rollingStock.length,
                movesForward: trainDto.movesForward,
                firstRollingStockName: rollingStock[trainDto.movesForward ? 0 : rollingStock.length - 1]?.name,
                lastRollingStockName: rollingStock[trainDto.movesForward ? rollingStock.length - 1 : 0]?.name,
            };
            this.trainListMap.set(trainListDto.id, trainListDto);

            const train: TrainDto = {
                ...trainListDto,
                rollingStock,
                length: trainDto.length,
                direction: trainDto.direction,
                speed: trainDto.speed,
            };

            this.trainMap.set(train.id, train);
        });

        this.state = state;
    };

    getTrainList(trackType: string): TrainListDto[] {
        return Array.from(this.trainListMap.values())
            .filter((v: TrainListDto) => v.trackType === trackType)
            .sort((a, b) => a.id.localeCompare(b.id, "de"));
    }

    getTrain(trainId: string): TrainDto {
        return this.trainMap.get(trainId);
    }

    getTrainType(train: TrainLuaDto): TrainType {
        if (this.rollingStockSelector.rollingStockInTrain(train.id, 0)) {
            return calcTrainType(
                this.rollingStockSelector.rollingStockInTrain(train.id, 0).modelType,
                train.rollingStockCount,
            );
        } else {
            return TrainType.TrainElectric;
        }
    }
}
