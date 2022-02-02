using Newtonsoft.Json;

namespace ShoppingBackend.Models
{
    public class Item
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("quantity")]
        public string Quantity { get; set; }

        [JsonProperty("isBought")]
        public bool Bought { get; set; }
    }
}