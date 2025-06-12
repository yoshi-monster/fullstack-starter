import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import gleam/result
import gleam/set.{type Set}

pub const vite_url = "http://localhost:5173"

pub type Context {
  Context(
    //
    mode: Mode,
    client_static: String,
    server_static: String,
    manifest: Manifest,
  )
}

pub type Mode {
  Production
  Development
  Test
}

pub type Manifest {
  Manifest(chunks: Dict(String, ManifestChunk))
}

pub fn empty_manifest() -> Manifest {
  Manifest(chunks: dict.new())
}

pub type ManifestChunk {
  ManifestChunk(file: String, is_entry: Bool, imports: List(String))
}

pub fn manifest_decoder() -> Decoder(Manifest) {
  use chunks <- decode.then(decode.dict(decode.string, manifest_chunk_decoder()))

  decode.success(Manifest(chunks))
}

fn manifest_chunk_decoder() -> Decoder(ManifestChunk) {
  use file <- decode.field("file", decode.string)

  use is_entry <- decode.optional_field("isEntry", False, decode.bool)

  use imports <- decode.optional_field(
    "imports",
    [],
    decode.list(decode.string),
  )

  decode.success(ManifestChunk(file:, is_entry:, imports:))
}

pub fn get_entry_point(
  manifest: Manifest,
  name: String,
) -> Result(List(String), Nil) {
  case dict.get(manifest.chunks, name) {
    Ok(entry) if entry.is_entry -> {
      let files = [entry.file]
      let seen = set.from_list([name])
      collect_files(manifest, entry.imports, seen, files)
    }

    _ -> Error(Nil)
  }
}

fn collect_files(
  manifest: Manifest,
  imports: List(String),
  seen: Set(String),
  files: List(String),
) -> Result(List(String), Nil) {
  case imports {
    [] -> Ok(files)
    [dependency, ..imports] ->
      case set.contains(seen, dependency) {
        True -> collect_files(manifest, imports, seen, files)
        False -> {
          use entry <- result.try(dict.get(manifest.chunks, dependency))
          let imports = list.append(entry.imports, imports)
          let seen = set.insert(seen, dependency)
          let files = [entry.file, ..files]
          collect_files(manifest, imports, seen, files)
        }
      }
  }
}
