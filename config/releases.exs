import Config

help_desk_config =
  "CONFIG"
  |> System.fetch_env!()
  |> Jason.decode!()

config :help_desk,
  producer:
    {BroadwaySQS.Producer,
     queue_url: help_desk_config["queue_url"],
     config: [
       access_key_id: help_desk_config["access_key_id"],
       secret_access_key: help_desk_config["secret_access_key"],
       region: help_desk_config["region"]
     ]}

config :zen_ex,
  subdomain: help_desk_config["ZENDESK_DOMAIN"],
  api_token: help_desk_config["ZENDESK_TOKEN"],
  user: help_desk_config["ZENDESK_EMAIL"],
  custom_fields: [
    order_id: help_desk_config["ZENDESK_FIELD_ORDER_ID"],
    product_model: help_desk_config["ZENDESK_FIELD_PRODUCT_MODEL"],
    product_serial: help_desk_config["ZENDESK_FIELD_PRODUCT_SERIAL"],
    security_codes: help_desk_config["ZENDESK_FIELD_SECURITY_CODES"]
  ]
