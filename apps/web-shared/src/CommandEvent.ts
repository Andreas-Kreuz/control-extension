export enum CommandEvent {
  // System room for command-related coordination.
  Room = '[Command Event]',
  Send = '[Command Event] Send',
  ChangeCamToStatic = '[Command Event] Change Cam',
  ChangeCamToTrain = '[Command Event] Change Cam to Train',
  ChangeCamToRollingStock = '[Command Event] Change Cam to RollingStock',
  ChangeSetting = '[Command Event] Change Setting',
  SetRollingStockAxis = '[Command Event] Set RollingStock Axis',
  SetTrainSpeed = '[Command Event] Set Train Speed',
  SetTrainCoupling = '[Command Event] Set Train Coupling',
  SetTrainLight = '[Command Event] Set Train Light',
}
