# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class OverseasPassportsTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(albania algeria afghanistan australia austria azerbaijan bahamas bangladesh benin british-indian-ocean-territory burma burundi cambodia cameroon congo georgia greece haiti india iran iraq ireland italy jamaica jordan kenya kyrgyzstan malta nepal nigeria pakistan pitcairn-island syria south-africa spain st-helena-ascension-and-tristan-da-cunha tanzania timor-leste turkey ukraine united-kingdom uzbekistan yemen zimbabwe vietnam)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'overseas-passports'
  end

  ## Q1
  should "ask which country you are in" do
    assert_current_node :which_country_are_you_in?
  end

  # Afghanistan (An example of bespoke application process).
  context "answer Afghanistan" do
    setup do
      worldwide_api_has_organisations_for_location('afghanistan', read_fixture_file('worldwide/afghanistan_organisations.json'))
      add_response 'afghanistan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'afghanistan'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          add_response 'afghanistan'
          assert_state_variable :application_type, 'ips_application_3'
          assert_current_node :ips_application_result
          assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
          assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
          assert_phrase_list :send_your_application, [:send_application_non_uk_visa_apply_renew_old_replace, :send_application_embassy_address]
        end
      end
    end

    context "answer renewing" do
      setup do
        add_response 'renewing_new'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_state_variable :application_type, 'ips_application_3'
          assert_current_node :ips_application_result
          assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
          assert_phrase_list :send_your_application, [:send_application_non_uk_visa_renew_new, :send_application_embassy_address]
        end
      end
    end
  end # Afghanistan

  # Iraq (An example of ips 1 application with some conditional phrases).
  context "answer Iraq" do
    setup do
      worldwide_api_has_organisations_for_location('iraq', read_fixture_file('worldwide/iraq_organisations.json'))
      add_response 'iraq'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'iraq'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask the country of birth" do
          assert_current_node :country_of_birth?
        end
        context "answer UK" do
          setup do
            add_response 'united-kingdom'
          end
          should "give the result and be done" do
            assert_current_node :ips_application_result
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
            assert_phrase_list :send_your_application, [:send_application_durham]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_iraq, :getting_your_passport_uk_visa_where_to_collect, :getting_your_passport_id_apply_renew_old_replace]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_match /Millburngate House/, outcome_body
          end
        end
      end
    end
  end # Iraq

  context "answer Benin, renewing old passport" do
    setup do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
      add_response 'benin'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
    end
    should "give the result with alternative embassy details" do
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_benin, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'austria'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "give the result and be done" do
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_current_node :country_of_birth?
        end
        context "answer Greece" do
          setup do
            add_response 'greece'
          end

          should "use the greek document group in the results" do
            assert_state_variable :supporting_documents, 'ips_documents_group_2'
          end

          should "give the result" do
            assert_current_node :ips_application_result_online
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
          end
        end
      end
    end # Applying

    context "answer renewing old blue or black passport" do
      setup do
        add_response 'renewing_old'
        add_response 'adult'
      end
      should "ask which country you were born in" do
        assert_current_node :country_of_birth?
      end
    end # Renewing old style passport
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_state_variable :supporting_documents, 'ips_documents_group_1'
          assert_current_node :ips_application_result_online
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
          assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
          assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
          assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
          assert_state_variable :embassy_address, nil
        end
      end
    end # Replacing
  end # Austria - IPS_application_1

  context "answer Spain, an example of online application, doc group 1" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
      assert_match /the passport numbers of both parents/, outcome_body
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :child_passport_costs_replacing_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
    end
  end

  context "answer Greece, an example of online application, doc group 2" do
    setup do
      worldwide_api_has_organisations_for_location('greece', read_fixture_file('worldwide/greece_organisations.json'))
      add_response 'greece'
    end
    should "show how to apply online" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_2]
      assert_match /Your application will take at least 4 weeks/, outcome_body
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :child_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_2]
    end
  end

  context "answer Vietnam, an example of online application, doc group 3" do
    setup do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
    end
    should "show how to apply online" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_3]
    end
    should "use the document group of the country of birth - Spain (which is 1)" do
      add_response 'applying'
      add_response 'adult'
      add_response 'spain'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
    end
  end

  # Albania (an example of IPS application 2).
  context "answer Albania" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'albania'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask which country you were born in" do
          assert_current_node :country_of_birth?
        end
        context "answer Spain" do
          should "give the application result" do
            add_response "spain"
            assert_current_node :ips_application_result_online
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_1'
          end
        end
        context "answer UK" do
          should "give the application result with the UK documents" do
            add_response "united-kingdom"
            assert_current_node :ips_application_result_online
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_3]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_3'
          end
        end
      end
    end # Applying
  end # Albania - IPS_application_2
  
  # Ajerbaijan (an example of IPS application 3 and UK Visa centre).
  context "answer Azerbaijan" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'azerbaijan'
    end
    context "answer replacing adult passport" do
      setup do
        add_response 'replacing'
        add_response 'adult'
        assert_state_variable :application_type, 'ips_application_3'
        assert_state_variable :ips_number, "3"
      end
      should "give the IPS application result" do
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :send_your_application, [:send_application_uk_visa_apply_renew_old_replace, :send_application_address_azerbaijan]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_uk_visa_centre, :getting_your_passport_contact_and_id]
      end
    end # Applying
  end # Azerbaijan - IPS_application_3

  # Burundi (An example of IPS 3 application with some conditional phrases).
  context "answer Burundi" do
    setup do
      worldwide_api_has_organisations_for_location('burundi', read_fixture_file('worldwide/burundi_organisations.json'))
      add_response 'burundi'
    end

    should "give the correct result when renewing new style passport" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_phrase_list :send_your_application,
        [:send_application_non_uk_visa_renew_new, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_burundi_renew_new]
    end

    should "give the correct result when renewing old style passport" do
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :send_your_application, [
        :send_application_non_uk_visa_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end

    should "give the correct result when applying for the first time" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :send_your_application, [
        :send_application_non_uk_visa_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end

    should "give the correct result when replacing lost or stolen passport" do
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :send_your_application, [
        :send_application_non_uk_visa_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end
  end # Burundi

  context "answer Ireland, replacement, adult passport" do
    should "give the ips online application result" do
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'ireland'
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Ireland (FCO with custom phrases)

  context "answer India" do
    setup do
      worldwide_api_has_organisations_for_location('india', read_fixture_file('worldwide/india_organisations.json'))
      add_response 'india'
    end
    context "applying, adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'india'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_16_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3_india, :send_application_ips3_must_post, :send_application_embassy_address]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_india, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_india]
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_5_weeks, :how_long_it_takes_ips3]
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_5_weeks, :how_long_it_takes_ips3]
      end
    end
  end # India

  context "answer Tanzania, replacement, adult passport" do
    should "give the ips online result with custom phrases" do
      worldwide_api_has_organisations_for_location('tanzania', read_fixture_file('worldwide/tanzania_organisations.json'))
      add_response 'tanzania'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_djibouti_tanzania, :how_long_additional_time_online]
    end
  end # Tanzania

  context "answer Congo, replacement, adult passport" do
    should "give the result with custom phrases" do
      worldwide_api_has_organisations_for_location('congo', read_fixture_file('worldwide/congo_organisations.json'))
      add_response 'congo'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_congo, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Congo

  context "answer Malta, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('malta', read_fixture_file('worldwide/malta_organisations.json'))
      add_response 'malta'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
    end
  end # Malta (IPS1 with custom phrases)

  context "answer Italy, replacement, adult passport" do
    should "give the IPS online result" do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_2]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Italy (IPS online result)

  context "answer Jordan, replacement, adult passport" do
    should "give the ips1 result with custom phrases" do
      worldwide_api_has_organisations_for_location('jordan', read_fixture_file('worldwide/jordan_organisations.json'))
      add_response 'jordan'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :getting_your_passport, [:getting_your_passport_jordan]
      assert_current_node :ips_application_result
      assert_match /Millburngate House/, outcome_body
    end
  end # Jordan (IPS1 with custom phrases)

  context "answer Pitcairn Island, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('pitcairn-island', read_fixture_file('worldwide/pitcairn-island_organisations.json'))
      add_response 'pitcairn-island'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_pitcairn-island"]
      assert_phrase_list :send_your_application, [:"send_application_address_pitcairn-island"]
      assert_phrase_list :cost, [:"passport_courier_costs_ips3_pitcairn-island", :adult_passport_costs_ips3,
 :passport_costs_ips3]
    end
  end # Pitcairn Island (IPS1 with custom phrases)

  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('ukraine', read_fixture_file('worldwide/ukraine_organisations.json'))
      add_response 'ukraine'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ukraine]
      assert_phrase_list :send_your_application, [:send_application_ips3_ukraine_apply_renew_old_replace, :send_application_address_ukraine]
    end
  end # Ukraine (IPS3 with custom phrases)
  
  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('ukraine', read_fixture_file('worldwide/ukraine_organisations.json'))
      add_response 'ukraine'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_uk_visa_centre, :getting_your_passport_contact, :getting_your_passport_id_renew_new]
      assert_phrase_list :send_your_application, [:send_application_uk_visa_renew_new, :send_application_address_ukraine]
    end
  end # Ukraine (IPS3 with custom phrases)
  
  context "answer nepal, renewing new, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('nepal', read_fixture_file('worldwide/nepal_organisations.json'))
      add_response 'nepal'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :send_your_application, [:send_application_uk_visa_renew_new, :"send_application_address_nepal"]
      assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]    
      assert_state_variable :send_colour_photocopy_bulletpoint, nil
    end
  end # nepal (IPS3 with custom phrases)
  
  context "answer nepal, lost or stolen, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('nepal', read_fixture_file('worldwide/pitcairn-island_organisations.json'))
      add_response 'nepal'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :send_your_application, [:send_application_uk_visa_apply_renew_old_replace, :"send_application_address_nepal"]
      assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_state_variable :send_colour_photocopy_bulletpoint, nil
    end
  end # nepal (IPS1 with custom phrases)

  context "answer Iran" do
    should "give a bespoke outcome stating an application is not possible in Iran" do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_iran]
    end
  end # Iran - no application outcome

  context "answer Syria" do
    should "give a bespoke outcome stating an application is not possible in Syria" do
      worldwide_api_has_organisations_for_location('syria', read_fixture_file('worldwide/syria_organisations.json'))
      add_response 'syria'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_syria]
    end
  end # Syria - no application outcome

  context "answer Cameroon, renewing, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('cameroon', read_fixture_file('worldwide/cameroon_organisations.json'))
      add_response 'cameroon'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_cameroon, :getting_your_passport_contact_and_id]
      assert_match /Millburngate House/, outcome_body
    end
  end # Cameroon (custom phrases)

  context "answer Kenya, applying, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'kenya'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_12_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_kenya, :getting_your_passport_contact_and_id]
      assert_state_variable :application_address, 'durham'
      assert_match /Millburngate House/, outcome_body
    end
  end # Kenya (custom phrases)

  context "answer Kenya, renewing_old, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'kenya'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_12_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_kenya, :getting_your_passport_contact_and_id]
      assert_state_variable :application_address, 'durham'
      assert_match /Millburngate House/, outcome_body
    end
  end # Kenya (custom phrases)

  context "answer Yemen, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_yemen, :getting_your_passport_uk_visa_where_to_collect, :getting_your_passport_id_apply_renew_old_replace]
      assert_match /Millburngate House/, outcome_body
    end
  end # Yemen

  context "answer Haiti, renewing new, adult passport" do
    should "give the ips result" do
      worldwide_api_has_organisations_for_location('haiti', read_fixture_file('worldwide/haiti_organisations.json'))
      add_response 'haiti'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
    end
  end # Haiti

  context "answer South Africa" do
    context "applying, adult passport" do
      should "give the IPS online result" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result_online
        assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
        assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
        assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      end
    end
    context "renewing, adult passport" do
      should "give the IPS online result" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result_online
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
        assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
        assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_2]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      end
    end
  end # South Africa (IPS online application)

  context "answer St Helena etc, renewing old, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_no_organisations_for_location('st-helena-ascension-and-tristan-da-cunha')
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      add_response 'renewing_old'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_fco]
      assert_phrase_list :cost, [:passport_courier_costs_pretoria_south_africa, :adult_passport_costs_pretoria_south_africa, :passport_costs_pretoria_south_africa]
      assert_match /^[\d,]+ South African Rand \| [\d,]+ South African Rand$/, current_state.costs_south_african_rand_adult_32
      assert_state_variable :supporting_documents, ''
    end
  end # St Helena (FCO with custom phrases)

  context "answer Nigeria, applying, adult passport" do
    should "give the result with custom phrases" do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
      add_response 'nigeria'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms_nigeria]
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_nigeria, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Nigeria

  context "answer Jamaica, replacement, adult passport" do
    should "give the ips result with custom phrase" do
      worldwide_api_has_organisations_for_location('jamaica', read_fixture_file('worldwide/jamaica_organisations.json'))
      add_response 'jamaica'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_2_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_match /Millburngate House/, outcome_body
    end
  end # Jamaica

  context "answer Zimbabwe, applying, adult passport" do
    setup do
      worldwide_api_has_organisations_for_location('zimbabwe', read_fixture_file('worldwide/zimbabwe_organisations.json'))
      add_response 'zimbabwe'
    end
    should "give the ips outcome with applying phrases" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
    should "give the ips outcome with renewing_new phrases" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
    should "give the ips outcome with replacing phrases" do
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
  end # Zimbabwe

  context "answer Bangladesh" do
    setup do
      worldwide_api_has_organisations_for_location('bangladesh', read_fixture_file('worldwide/bangladesh_organisations.json'))
      add_response 'bangladesh'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
        assert_phrase_list :send_your_application, [:send_application_ips3_bangladesh, :send_application_embassy_address]
      end
    end
    context "replacing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_16_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'bangladesh'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
      end
    end
  end # Bangladesh

  context "answer Pakistan" do
    setup do
      worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
      add_response 'pakistan'
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'pakistan'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3_pakistan, :send_application_ips3_must_post, :send_application_embassy_address]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :send_application_ips1_pakistan, :hmpo_1_application_form, :ips_documents_group_3]
      end
    end
  end # Pakistan

  context "answer Uzbekistan" do
    setup do
      worldwide_api_has_organisations_for_location('uzbekistan', read_fixture_file('worldwide/uzbekistan_organisations.json'))
      add_response 'uzbekistan'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_8_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :renewing_new_renewing_old, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_8_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      end
    end
  end # Uzbekistan

  context "answer Bahamas, applying, adult passport" do
    should "give the IPS online outcome" do
      worldwide_api_has_organisations_for_location('bahamas', read_fixture_file('worldwide/bahamas_organisations.json'))
      add_response 'bahamas'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
    end
  end # Bahamas

  context "answer british-indian-ocean-territory" do
    should "go to apply_in_neighbouring_country outcome" do
      worldwide_api_has_organisations_for_location('british-indian-ocean-territory', read_fixture_file('worldwide/british-indian-ocean-territory_organisations.json'))
      add_response 'british-indian-ocean-territory'
      assert_current_node :apply_in_neighbouring_country
      assert_state_variable :title_output, 'British Indian Ocean Territory'
    end
  end # british-indian-ocean-territory

  context "answer turkey, doc group 1" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
      assert_match /the passport numbers of both parents/, outcome_body
    end
  end

  context "answer Algeria" do
    setup do
      worldwide_api_has_organisations_for_location('algeria', read_fixture_file('worldwide/algeria_organisations.json'))
      add_response 'algeria'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_uk_visa_renew_new, :send_application_address_algeria]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_uk_visa_centre, :getting_your_passport_contact, :getting_your_passport_id_renew_new]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_uk_visa, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_uk_visa_apply_renew_old_replace, :send_application_address_algeria]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_uk_visa_centre, :getting_your_passport_contact_and_id]
      end
    end
  end # Algeria

  context "answer Burma" do
    setup do
      worldwide_api_has_organisations_for_location('burma', read_fixture_file('worldwide/burma_organisations.json'))
      add_response 'burma'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :renewing_new_renewing_old, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_burma, :getting_your_passport_contact, :getting_your_passport_id_renew_new]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_burma, :getting_your_passport_contact, :getting_your_passport_id_apply_renew_old_replace]
      end
    end
  end # Burma

  context "answer Cambodia, testing getting your passport" do
    setup do
      worldwide_api_has_organisations_for_location('cambodia', read_fixture_file('worldwide/cambodia_organisations.json'))
      add_response 'cambodia'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :getting_your_passport, [:getting_your_passport_cambodia]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :getting_your_passport, [:getting_your_passport_cambodia]
      end
    end
  end # Cambodia

  context "answer Kyrgyzstan, testing for embassy link" do
    should "give the neighbouring country outcome" do
      worldwide_api_has_organisations_for_location('kyrgyzstan', read_fixture_file('worldwide/kyrgyzstan_organisations.json'))
      add_response 'kyrgyzstan'
      assert_current_node :apply_in_neighbouring_country
      assert_phrase_list :emergency_travel_help, [:emergency_travel_help_kyrgyzstan]
      assert_state_variable :title_output, 'Kyrgyzstan'
    end
  end # Kyrgyzstan

  context "answer Georgia, testing for ips2 courier costs" do
    should "give the IPS outcome" do
      worldwide_api_has_organisations_for_location('georgia', read_fixture_file('worldwide/georgia_organisations.json'))
      add_response 'georgia'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ips2_uk_visa, :adult_passport_costs_ips2, :passport_costs_ips2]
    end
  end # Georgia

  context "answer Timor-Leste, testing sending application" do
    setup do
      worldwide_api_has_organisations_for_location('timor-leste', read_fixture_file('worldwide/timor-leste_organisations.json'))
      add_response 'timor-leste'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :send_your_application, [:"send_application_timor-leste_intro", :"send_application_ips3_timor-leste_renew_new", :"send_application_address_timor-leste"]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :send_your_application, [:"send_application_timor-leste_intro", :"send_application_ips3_timor-leste_apply_renew_old_replace", :"send_application_address_timor-leste"]
      end
    end
  end # Cambodia


end
