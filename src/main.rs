use pipewire::{Context, MainLoop, spa::ReadableDict};

//                if object.type_ != "PipeWire:Interface:Metadata" {
//                    .metadata_name .as_ref() .unwrap() != "default"

//                if metadata.key != "default.configured.audio.sink" {
//                let MetadataValue::ObjectName { name } = &metadata.value else {

// fn next_audio_sink_id(&self) -> Option<ObjectId> {
//     self.0.iter().cycle().find_map(|object| {
//         if object.type_ != "PipeWire:Interface:Node" {
//             return None;
//         }

//         let info = object.info.as_ref().unwrap();

//         let Some(media_class) = info.props.media_class.as_ref() else {
//             return None;
//         };

//         if media_class != "Audio/Sink" {
//             return None;
//         }

//         let node_name = info.props.node_name.as_ref().unwrap();

//         if node_name == self.default_audio_sink_name() {
//             return None;
//         }

//         Some(object.id)
//     })
// }

//fn main() {
//    let dump = Dump::get();
//    let next_audio_sink_id = dump.next_audio_sink_id().unwrap();
//    let command = &mut Command::new("wpctl");
//    command.args(["set-default", &next_audio_sink_id.0.to_string()]);
//    let status = command.status().unwrap();
//    assert!(status.success());
//}

fn main() {
    let mainloop = MainLoop::new().unwrap();
    let context = Context::new(&mainloop).unwrap();
    let core = context.connect(None).unwrap();
    let registry = core.get_registry().unwrap();

    let something = registry
        .add_listener_local()
        .global(|global_object| {
            dbg!(global_object);
            // for item in global.props.iter() {
            //   dbg!(item);
            // }
        })
        .register();

    mainloop.run();
}
