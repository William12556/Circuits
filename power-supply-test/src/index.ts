import { PCB } from '@typecad/typecad';
import { Resistor, Capacitor } from '@typecad/passives/0805';

let typecad = new PCB('power-supply-test');

// Voltage divider resistors
let r1 = new Resistor({ 
  value: '10kohm', 
  reference: 'R1',
  pcb: { x: 100, y: 100, rotation: 0 }
});

let r2 = new Resistor({ 
  value: '10kohm', 
  reference: 'R2',
  pcb: { x: 100, y: 110, rotation: 0 }
});

// Filter capacitor
let c1 = new Capacitor({ 
  value: '100uF', 
  voltage: '25V',
  reference: 'C1',
  pcb: { x: 110, y: 105, rotation: 90 }
});

// Connections
typecad.named('vin').net(r1.pin(1), c1.pin(1));
typecad.named('vout').net(r1.pin(2), r2.pin(1));
typecad.named('gnd').net(r2.pin(2), c1.pin(2));

typecad.create(r1, r2, c1);
