package.path = package.path .. ";../lib/?.lua"
require "lunit"
local utils = require 'utils'

module( "enhanced", package.seeall, lunit.testcase )

local foobar = nil

function setup()
end

function teardown()
end

function test_color()
  local r,g,b,a = utils.color("000000")
  assert_equal(0, r)
  assert_equal(0, g)
  assert_equal(0, b)

  local r,g,b,a = utils.color("000")
  assert_equal(0, r)
  assert_equal(0, g)
  assert_equal(0, b)

  local r,g,b,a = utils.color("FFF")
  assert_equal(255, r)
  assert_equal(255, g)
  assert_equal(255, b)

  local r,g,b,a = utils.color("101010")
  assert_equal(16, r)
  assert_equal(16, g)
  assert_equal(16, b)

  local r,g,b,a = utils.color("1000FF")
  assert_equal(16, r)
  assert_equal(0, g)
  assert_equal(255, b)
end

function test_setDefault()
    local params = {a = 1, b = 2}
    local default = {a = 3, c = 4}
    local result = utils.setDefault(params, default)
    local expected = {a = 1, b = 2, c = 4}
    for k, v in pairs(expected) do
        assert_equal(v, result[k], "key:" .. k)
    end

    local result = utils.setDefault(nil, default)
    for k, v in pairs(default) do
        assert_equal(v, result[k], "key:" .. k)
    end
end

function testEqual()
  assert_true(utils.equal(nil, nil), "both nil")
  assert_false(utils.equal(nil, ""), "left nil")
  assert_false(utils.equal(1, nil), "right nil")
  assert_false(utils.equal(1, "1"), "number string")
  assert_false(utils.equal(1, 2), "diff value")
  assert_false(utils.equal({a=1}, {a=3}), "diff value")
  assert_false(utils.equal({a=1}, {b=1}), "diff key")
  assert_false(utils.equal({a=1}, {a=1, b=1}), "diff size")
  assert_true(utils.equal({a=1, b=1}, {a=1, b=1}), "table equal")
  assert_true(utils.equal({a=1, b={a=1}}, {a=1, b={a=1}}), "table equal recursively")
end

function testMakeQuery()
  assert_equal("", utils.makeQuery(), "nil")
  assert_equal("", utils.makeQuery({}), "empty")
  assert_equal("a=1", utils.makeQuery({a=1}), "normal")
  assert_equal("a=1&b=2", utils.makeQuery({a=1,b=2}), "multi")
  assert_equal("a=1&b=%E3%81%82", utils.makeQuery({a=1,b="あ"}), "multi byte character")
  assert_equal("a=1&b=%7Ba%3D1%7D", utils.makeQuery({a=1,b="{a=1}"}), "json")
end

function testEquals()
  assert_true(utils.isEmpty(nil), "nil")
  assert_true(utils.isEmpty(false), "false")
  assert_true(utils.isEmpty(""), "empty string")
  assert_true(utils.isEmpty({}), "empty table")
  assert_true(utils.isEmpty(0), "0")
  assert_true(utils.isEmpty(0.0), "0.0")
  assert_false(utils.isEmpty("a"), "'a'")
  assert_false(utils.isEmpty("0"), "'0'")
  assert_false(utils.isEmpty({{}}), "empty in empty")
end
function testIsType()
  assert_true(utils.isTable({}), "table")
  assert_false(utils.isTable(function()end), "table but function")
  assert_false(utils.isTable(0), "table but number ")
  assert_false(utils.isTable(""), "table but string")
  assert_false(utils.isTable(nil), "table but nil")
  assert_true(utils.isFunction(function()end), "function")
  assert_false(utils.isFunction({}), "function but table")
  assert_false(utils.isFunction(0), "function but number ")
  assert_false(utils.isFunction(""), "function but string")
  assert_false(utils.isFunction(nil), "function but nil")
  assert_true(utils.isNumber(0), "number")
  assert_false(utils.isNumber({}), "number but table")
  assert_false(utils.isNumber(function() end), "number but function ")
  assert_false(utils.isNumber(""), "number but string")
  assert_false(utils.isNumber(nil), "number but nil")
  assert_true(utils.isString(""), "string")
  assert_false(utils.isString({}), "string but table")
  assert_false(utils.isString(function() end), "string but function ")
  assert_false(utils.isString(0), "string but number")
  assert_false(utils.isString(nil), "string but nil")
end
