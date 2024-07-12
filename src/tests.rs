use crate::Dump;

#[test]
fn a() {
    const DUMP: &str = include_str!("../fixtures/48,_62_.json");
    let dump = Dump::from_json(DUMP);
    let next = dump.next_audio_sink_id();
    assert_eq!(next.0, 48);
}

#[test]
fn b() {
    const DUMP: &str = include_str!("../fixtures/_48_,62.json");
    let dump = Dump::from_json(DUMP);
    let next = dump.next_audio_sink_id();
    assert_eq!(next.0, 62);
}

#[test]
fn c() {
    const DUMP: &str = include_str!("../fixtures/_48_.json");
    let dump = Dump::from_json(DUMP);
    let next = dump.next_audio_sink_id();
    assert_eq!(next.0, 48);
}
