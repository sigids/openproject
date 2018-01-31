#-- encoding: UTF-8

#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class CustomActions::CustomFieldAction < CustomActions::Base
  def self.key
    :"custom_field_#{custom_field.id}"
  end

  def self.custom_field
    raise NotImplementedError
  end

  def custom_field
    self.class.custom_field
  end

  def human_name
    custom_field.name
  end

  def self.all
    WorkPackageCustomField
      .order(:name)
      .map do |cf|
        create_subclass(cf)
      end
  end

  def self.for(key)
    match_result = key.match /custom_field_(\d+)/

    if match_result && (cf = CustomField.find_by(id: match_result[0]))
      create_subclass(cf)
    end
  end

  def self.create_subclass(custom_field)
    klass = Class.new(CustomActions::CustomFieldAction)
    klass.define_singleton_method(:custom_field) do
      custom_field
    end

    klass.prepend(strategy(custom_field))
    klass
  end
  private_class_method :create_subclass

  def self.strategy(custom_field)
    case custom_field.field_format
    when 'string'
      CustomActions::Strategies::String
    when 'text'
      CustomActions::Strategies::Text
    when 'int'
      CustomActions::Strategies::Integer
    when 'float'
      CustomActions::Strategies::Float
    when 'date'
      CustomActions::Strategies::Date
    when 'bool'
      CustomActions::Strategies::Boolean
    when 'list', 'version', 'user'
      CustomActions::Strategies::AssociatedCustomField
    end
  end

  private_class_method :strategy
end
