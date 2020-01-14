(** You can use and override this configuration by setting the values of
    environment variables with names derived from the names in the [S]
    module type below by prefixing [REWEB__]. For example,
    [REWEB__buf_size]. You can set up your own configuration by using
    the functions below.

    Another technique to customize configuration is creating a custom
    config module. However that is primarily intended for testing and is
    covered in the manual: {!Manual.Ch06_Configuration}.

    You can also create a configuration module in your own application
    that reads values from the system environment, by using the
    (type-safe) functions below. *)

let string name = Sys.getenv_opt @@ "REWEB__" ^ name
(** [string(name)] gets a value from the system environment variable
    with the name [REWEB__name]. The following functions all use the
    same name prefix and work for their specific types. *)

let bool name = Option.bind (string name) bool_of_string_opt

let char name = Option.bind (string name) @@ function
  | "" -> None
  | string -> Some (String.unsafe_get string 0)
(** [char(name)] gets the first character of the value of the system
    environment variable named [REWEB__name]. *)

let float name = Option.bind (string name) float_of_string_opt
let int name = Option.bind (string name) int_of_string_opt

module type S = sig
  val secure_cookies : bool
  (** Whether to use secure i.e. HTTPS-only cookies. *)

  val buf_size : int
  (** Buffer size for internal string/bigstring handling. *)
end
(** The known ReWeb configuration settings. *)

module Default : S = struct
  let secure_cookies =
    "cookie__secure" |> bool |> Option.value ~default:true

  let buf_size = "buf_size"
    |> int
    |> Option.value ~default:(Lwt_io.default_buffer_size ())
end
(** Default values for ReWeb configuration settings. *)
