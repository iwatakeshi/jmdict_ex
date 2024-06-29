defmodule JMDictEx.Models.Release do
  @derive {Poison.Encoder, only: [:atoms]}
  defstruct [
    :url,
    :assets_url,
    :upload_url,
    :html_url,
    :id,
    :node_id,
    :tag_name,
    :target_commitish,
    :name,
    :draft,
    :author,
    :prerelease,
    :created_at,
    :published_at,
    :assets,
    :tarball_url,
    :zipball_url,
    :body
  ]

  defmodule Author do
    @derive {Poison.Encoder, only: [:atoms]}
    defstruct [
      :login,
      :id,
      :node_id,
      :avatar_url,
      :gravatar_id,
      :url,
      :html_url,
      :followers_url,
      :following_url,
      :gists_url,
      :starred_url,
      :subscriptions_url,
      :organizations_url,
      :repos_url,
      :events_url,
      :received_events_url,
      :type,
      :site_admin
    ]

    @type t :: %__MODULE__{
            login: String.t(),
            id: non_neg_integer(),
            node_id: String.t(),
            avatar_url: String.t(),
            gravatar_id: String.t(),
            url: String.t(),
            html_url: String.t(),
            followers_url: String.t(),
            following_url: String.t(),
            gists_url: String.t(),
            starred_url: String.t(),
            subscriptions_url: String.t(),
            organizations_url: String.t(),
            repos_url: String.t(),
            events_url: String.t(),
            received_events_url: String.t(),
            type: String.t(),
            site_admin: boolean()
          }
  end

  defmodule Asset do
    @derive {Poison.Encoder, only: [:atoms]}
    defstruct [
      :url,
      :id,
      :node_id,
      :name,
      :label,
      :uploader,
      :content_type,
      :state,
      :size,
      :download_count,
      :created_at,
      :updated_at,
      :browser_download_url
    ]

    @type t :: %__MODULE__{
            url: String.t(),
            id: non_neg_integer(),
            node_id: String.t(),
            name: String.t(),
            label: String.t(),
            uploader: Author.t(),
            content_type: String.t(),
            state: String.t(),
            size: non_neg_integer(),
            download_count: non_neg_integer(),
            created_at: String.t(),
            updated_at: String.t(),
            browser_download_url: String.t()
          }
  end

  @type t :: %__MODULE__{
          url: String.t(),
          assets_url: String.t(),
          upload_url: String.t(),
          html_url: String.t(),
          id: non_neg_integer(),
          node_id: String.t(),
          tag_name: String.t(),
          target_commitish: String.t(),
          name: String.t(),
          draft: boolean(),
          author: Author.t(),
          prerelease: boolean(),
          created_at: String.t(),
          published_at: String.t(),
          assets: [Asset.t()],
          tarball_url: String.t(),
          zipball_url: String.t(),
          body: String.t()
        }
end
