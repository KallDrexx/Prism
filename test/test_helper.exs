ExUnit.start(capture_log: true)

case File.ls("./test/support") do
  {:ok, files} -> Enum.each(files, fn(file) -> Code.require_file "support/#{file}", __DIR__ end)
  _ ->  :ok
end


