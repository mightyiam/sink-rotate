use crate::Dump;

#[test]
fn rotate_usb_to_builtin() {
    const DUMP: &str = include_str!("../fixtures/usb-to-builtin.json");
    let dump = Dump::from_json(DUMP);
    let next = dump.next_audio_sink_id();
    assert_eq!(next.0, 48);
}

#[test]
fn rotate_builtin_to_usb() {
    const DUMP: &str = include_str!("../fixtures/builtin-to-usb.json");
    let dump = Dump::from_json(DUMP);
    let next = dump.next_audio_sink_id();
    assert_eq!(next.0, 62);
}

#[test]
#[should_panic(expected = "audio sinks not two")]
fn one_sink_available() {
    const DUMP: &str = include_str!("../fixtures/one-sink-available.json");
    let dump = Dump::from_json(DUMP);
    dump.next_audio_sink_id();
}
