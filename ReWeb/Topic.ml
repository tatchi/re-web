module Make(Msg : sig type t end) = struct
  module Cache = Cache.InMemory(struct
    type t = Msg.t Lwt_stream.t

    let equal = (==)
    let hash = Hashtbl.seeded_hash
  end)

  type t = (Msg.t option -> unit) Cache.t
  type subscription = Cache.key * t

  let make = Cache.make

  let publish topic ~msg =
    Cache.iter topic ~f:(fun _ push -> push (Some msg))

  let subscribe topic =
    let stream, push = Lwt_stream.create () in
    let open Let.Lwt in
    let+ () = Cache.add topic ~key:stream push in
    stream, topic

  let stream = fst

  let unsubscribe (stream, topic) = Cache.access topic begin fun table ->
    let push = Cache.Table.find table stream in
    Cache.Table.remove table stream;
    push None
  end

  let close topic = Cache.access topic begin fun table ->
    Cache.Table.iter (fun _ push -> push None) table;
    Cache.Table.reset table
  end
end

