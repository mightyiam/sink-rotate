#[cfg(test)]
mod tests;

use std::process::Command;

use serde::Deserialize;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
struct Object {
    id: ObjectId,
    #[serde(rename = "type")]
    type_: String,
    info: Option<ObjectInfo>,
    metadata: Option<Vec<Metadata>>,
    props: Option<ObjectProps>,
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Deserialize)]
struct ObjectProps {
    #[serde(rename = "metadata.name")]
    metadata_name: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
struct Metadata {
    key: String,
    value: MetadataValue,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
#[serde(untagged)]
enum MetadataValue {
    Integer(usize),
    String(String),
    ObjectName { name: NodeName },
    Other(serde_json::Value),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Deserialize)]
struct ObjectId(usize);

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Deserialize)]
struct ObjectInfo {
    props: InfoProps,
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Deserialize)]
struct InfoProps {
    #[serde(rename = "media.class")]
    media_class: Option<String>,
    #[serde(rename = "metadata.name")]
    metadata_name: Option<String>,
    #[serde(rename = "node.name")]
    node_name: Option<NodeName>,
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Deserialize)]
struct NodeName(String);

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
struct Dump(Vec<Object>);

impl Dump {
    fn from_json(dump: &str) -> Self {
        let objects: Vec<Object> = serde_json::from_str(dump).unwrap();
        Self(objects)
    }

    fn defaults(&self) -> &Vec<Metadata> {
        self.0
            .iter()
            .find_map(|object| {
                if object.type_ != "PipeWire:Interface:Metadata" {
                    return None;
                }

                if object
                    .props
                    .as_ref()
                    .unwrap()
                    .metadata_name
                    .as_ref()
                    .unwrap()
                    != "default"
                {
                    return None;
                }

                Some(object.metadata.as_ref().unwrap())
            })
            .unwrap()
    }

    fn default_audio_sink_name(&self) -> &NodeName {
        let defaults = self.defaults();

        defaults
            .iter()
            .find_map(|metadata| {
                if metadata.key != "default.configured.audio.sink" {
                    return None;
                }

                let MetadataValue::ObjectName { name } = &metadata.value else {
                    return None;
                };

                Some(name)
            })
            .unwrap()
    }

    fn next_audio_sink_id(&self) -> ObjectId {
        let mut sinks = self
            .0
            .iter()
            .filter_map(|object| {
                if object.type_ != "PipeWire:Interface:Node" {
                    return None;
                }

                let info = object.info.as_ref().unwrap();

                let media_class = info.props.media_class.as_ref()?;

                if media_class != "Audio/Sink" {
                    return None;
                }

                let node_name = info.props.node_name.as_ref().unwrap();

                Some((object.id, node_name.clone()))
            })
            .collect::<Vec<(ObjectId, NodeName)>>();

        sinks.sort();

        if sinks.is_empty() {
            panic!("zero sinks found");
        }

        if let [(id, _)] = sinks.as_slice() {
            return *id;
        }

        let mut iter = sinks.iter().cycle();

        loop {
            let (_id, name) = iter.next().unwrap();
            if name == self.default_audio_sink_name() {
                return iter.next().unwrap().0;
            }
        }
    }
}

fn main() {
    let dump = Command::new("pw-dump").output().unwrap().stdout;
    let dump: String = String::from_utf8(dump).unwrap();
    let dump = Dump::from_json(&dump);
    let next_audio_sink_id = dump.next_audio_sink_id();
    let command = &mut Command::new("wpctl");
    command.args(["set-default", &next_audio_sink_id.0.to_string()]);
    let status = command.status().unwrap();
    assert!(status.success());
}
