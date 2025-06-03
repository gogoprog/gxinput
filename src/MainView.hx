package ;

import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

using StringTools;

typedef Device = {
    var name:String;
    var id:Int;
}

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {

    private var updatingSliders = false;
    private var matrix:Array<Float> = [];
    private var devices:Map<Int, Device> = [];
    private var listDeviceIds:Array<Int> = [];

    public function new() {
        super();

        for(i in 0...9) {
            matrix.push(0);
        }

        updateInputs();
        updateMatrixLabel();
    }

    @:bind(applyButton, MouseEvent.CLICK)
    private function onApply(e:MouseEvent) {
        var value = inputs.selectedIndex;
        var id = listDeviceIds[value];
        var device = devices[id];
        var values_str = matrix.join(" ");
        var command = "xinput set-prop " + id + " 'Coordinate Transformation Matrix' " + values_str;
        trace(command);
        var output = new sys.io.Process("bash", ["-c", command]).stdout.readAll().toString();
    }

    @:bind(closeButton, MouseEvent.CLICK)
    private function onClose(e:MouseEvent) {
        Sys.exit(0);
    }

    @:bind(xSlider, UIEvent.CHANGE)
    private function onX(e:UIEvent) {
        if(updatingSliders) { return; }

        var value = e.target.value / 100.0;
        matrix[0] = value;
        updateMatrixLabel();
    }

    @:bind(ySlider, UIEvent.CHANGE)
    private function onY(e:UIEvent) {
        if(updatingSliders) { return; }

        var value = e.target.value / 100.0;
        matrix[4] = value;
        updateMatrixLabel();
    }

    @:bind(inputs, UIEvent.CHANGE)
    private function onInputSelected(e:UIEvent) {
        var value = e.target.value;
        var id = listDeviceIds[value];
        var output = new sys.io.Process("bash", ["-c", "xinput list-props " + id + " | grep 'Transformation Matrix'"]).stdout.readAll().toString();
        trace(output);
        var parts = output.split(":");
        var values = parts[1].split(",");
        matrix = [];

        for(value in values) {
            matrix.push(Std.parseFloat(value));
        }

        trace(matrix);
        updateMatrixLabel();
        updatingSliders = true;
        xSlider.value = Std.int(matrix[0] * 100);
        ySlider.value = Std.int(matrix[4] * 100);
        updatingSliders = false;
    }

    private function updateMatrixLabel() {
        var text = "";
        trace("updateMatrixLabel");
        trace(matrix[0]);

        for(i in 0...3) {
            for(j in 0...3) {
                var formatted = Std.string(matrix[i*3 + j]).lpad(" ", 5);
                trace('$j,$i');
                trace(matrix[i*3 + j]);
                trace(formatted);
                text += formatted;

                if(i != 2 || j != 2) {
                    text += ", ";
                }
            }

            text += "\n";
        }

        matrixLabel.text = text;
    }

    private function updateInputs() {
        var output = new sys.io.Process("xinput", []).stdout.readAll().toString();
        var lines = output.split("\n");
        var ds = inputs.dataSource;
        ds.clear();
        listDeviceIds = [];

        for(line in lines) {
            var parts = line.split("id=");
            var right_parts = parts[1].split("\t");
            var id = Std.parseInt(right_parts[0]);
            var type = right_parts[1];
            var name = parts[0];

            if(type.indexOf("pointer") != -1) {
                ds.add({ text: name });
                listDeviceIds.push(id);
                devices.set(id, {name:name, id:id});
            }
        }
    }
}
