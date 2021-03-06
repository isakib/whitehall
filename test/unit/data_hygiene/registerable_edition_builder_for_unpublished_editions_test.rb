require "test_helper"
require "data_hygiene/registerable_edition_builder_for_unpublished_editions"

class RegisterableEditionBuilderForUnpublishedEditionsTest < ActiveSupport::TestCase
  setup do
    control_edition_1 = create(:published_edition)
    control_edition_2 = create(:draft_edition)
  end

  test "builds a set that includes editions that are unpublished and archived" do
    archived_edition = create(:edition, :unpublished, :archived)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(archived_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that are unpublished and deleted" do
    edition_to_delete = create(:unpublished_edition)
    edition_to_delete.delete!

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(edition_to_delete)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that have been republished" do
    unpublished_edition = create(:unpublished_edition)
    document = unpublished_edition.document

    unpublished_edition.delete!
    republished_edition = create(:published_edition, document: document)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(republished_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "live", registerable_editions.last.state
  end

  test "builds a set that excludes editions without related documents" do
    policy = create(:policy, :unpublished)
    supporting_page = create(:supporting_page, :unpublished, related_policies: [policy])
    supporting_page.delete!
    policy.delete!

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(supporting_page)

    assert_equal [], supporting_page.related_policies
    refute_includes registerable_editions, expected_registerable_edition
  end
end
