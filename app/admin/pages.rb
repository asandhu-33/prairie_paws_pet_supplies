ActiveAdmin.register Page do
  permit_params :slug, :title, :body

  actions :index, :show, :edit, :update

  index do
    selectable_column
    id_column
    column :slug
    column :title
    column :updated_at
    actions
  end

  filter :slug
  filter :title

  show do
    attributes_table do
      row :id
      row :slug
      row :title
      row :body do |page|
        simple_format(page.body)
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Page Details" do
      f.input :slug, input_html: { readonly: f.object.persisted? }
      f.input :title
      f.input :body, as: :text, input_html: { rows: 10 }
    end
    f.actions
  end
end