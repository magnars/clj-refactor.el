Feature: remove unused require

  Background:
    Given I have a project "cljr" in "tmp"
    And I have a clojure-file "tmp/src/cljr/core.clj"
    And I open file "tmp/src/cljr/core.clj"
    And I press "M-<"

  Scenario: Removes not used with :as
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :as s]
                [clojure.set :as st]
                [clj-time.core :as t]))

    (defn use-time []
      (t/now)
      (st/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.set :as st]
                [clj-time.core :as t]))

    (defn use-time []
      (t/now)
      (st/difference #{:a :b} #{:a :c}))
    """

  Scenario: Removes not used without :as
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :as s]
                [clojure.set :as st]
                [clojure.tools.cli]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (st/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.set :as st]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (st/difference #{:a :b} #{:a :c}))
    """

  Scenario: Removes if line commented out
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :as s]
                [clojure.set :as st]
                [clojure.tools.cli]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      ; (s/blank? "foobar")
      ;;;; (clojure.tools.cli/flag? "f")
      (st/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.set :as st]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      ; (s/blank? "foobar")
      ;;;; (clojure.tools.cli/flag? "f")
      (st/difference #{:a :b} #{:a :c}))
    """

  Scenario: removes require if all elements removed
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.set :as st]
                [clj-time.core]))

    (defn use-time []
      (count [:a :b :c]))
    """
    And I place the cursor before "count"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core)

    (defn use-time []
      (count [:a :b :c]))
    """

  Scenario: keeps it if referenced
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :refer [trim]]
                [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      ;;(trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      ;;(trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """

  Scenario: keeps it if referenced multiple
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :refer [trim blank? reverse]]
                [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (reverse "baz")
      (trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.string :refer [trim reverse]]
                [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (reverse "baz")
      (trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """

  Scenario: :refer combined with :as
    When I insert:
    """
    (ns cljr.core
      (:require [clojure.string :as st :refer [trim split reverse]]
                [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (st/split "foo bar" #" ")
      (trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure.string :as st :refer [trim split]]
                [clojure.set :refer [difference]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (st/split "foo bar" #" ")
      (trim "  foobar ")
      (difference #{:a :b} #{:a :c}))
    """

  Scenario: prefix list -- simple case
    When I insert:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string walk set]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (clojure.set/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string set]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (clojure.set/difference #{:a :b} #{:a :c}))
    """

  Scenario: prefix list with as
    When I insert:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string
                 [set :as st]
                 walk]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (st/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string 
                 [set :as st]]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (st/difference #{:a :b} #{:a :c}))
    """

  Scenario: prefix list with refer
    When I insert:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string walk
                 [set :refer [difference union]]]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clj-time.core]
                [clojure string 
                 [set :refer [difference]]]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (difference #{:a :b} #{:a :c}))
    """

  Scenario: keeps :refer :all
    When I insert:
    """
    (ns cljr.core
      (:require [clj-time.core :refer :all]
                [clojure string walk
                 [set :refer :all]]))

    (defn use-time []
      (now)
      (clojure.string/split "foo bar" #" ")
      (difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clj-time.core :refer :all]
                [clojure string 
                 [set :refer :all]]))

    (defn use-time []
      (now)
      (clojure.string/split "foo bar" #" ")
      (difference #{:a :b} #{:a :c}))
    """

  Scenario: simple after prefix list
    When I insert:
    """
    (ns cljr.core
      (:require [clojure string walk
                 [set :as st]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (st/difference #{:a :b} #{:a :c}))
    """
    And I place the cursor before "now"
    And I press "C-! rr"
    Then I should see:
    """
    (ns cljr.core
      (:require [clojure string 
                 [set :as st]]
                [clj-time.core]))

    (defn use-time []
      (clj-time.core/now)
      (clojure.string/split "foo bar" #" ")
      (st/difference #{:a :b} #{:a :c}))
    """
