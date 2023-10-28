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

use std::rc::Rc;

use futures::SinkExt;
use pipewire::{metadata::Metadata, spa::ReadableDict, types::ObjectType, Context, MainLoop};

#[tokio::main]
async fn main() {
    let (main_sender, _main_receiver) = futures::channel::mpsc::unbounded();
    let (pw_sender, pw_receiver) = pipewire::channel::channel::<()>();

    let task = tokio::task::spawn(async move {
        let mainloop = MainLoop::new().unwrap();
        let context = Context::new(&mainloop).unwrap();
        let core_ = context.connect(None).unwrap();
        let registry = core_.get_registry().unwrap();

        let _receiver = pw_receiver.attach(&mainloop, {
            let mainloop = mainloop.clone();

            move |_| {
                core_.sync(0).unwrap();
                mainloop.quit()
            }
        });

        let registry = Rc::new(registry);
        let registry_clone = Rc::clone(&registry);

        let _listener = registry
            .add_listener_local()
            .global(move |global_object| {
                let (Some(props), ObjectType::Metadata) =
                    (&global_object.props, &global_object.type_)
                else {
                    return;
                };

                let Some("default") = props.get("metadata.name") else {
                    return;
                };

                let metadata: Metadata = registry_clone.bind(global_object).unwrap();
                let _listener = metadata
                    .add_listener_local()
                    .property(|subject, key, type_, value| {
                        dbg!(subject, key, type_, value);
                        0
                    })
                    .register();

                dbg!(metadata);

                futures::executor::block_on(main_sender.clone().send(())).unwrap();
            })
            .register();

        mainloop.run();
    });

    task.await.unwrap();
}
