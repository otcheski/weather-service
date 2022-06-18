require 'date'

# Класс принимает данные из XML файла предоставленного сервисом www.meteoservice.ru
# Возвращает данные о погоде за два дня (сегодня-завтра)
# Формат данных описан по ссылке www.meteoservice.ru/content/export
class MeteoserviceForecast

  # словарь для определения облачности
  CLOUDINESS = %w[Ясно Малооблачно Облачно Пасмурно].freeze
  # словарь для типа осадков precipitation
  PRECIPITATION = { 3 => 'снег с дождем',
                    4 => 'Дождь',
                    5 => 'Ливень',
                    6 => 'Снег', 7 => 'Снег',
                    8 => 'Гроза',
                    9 => 'нет данных об осадках',
                    10 => 'Без осадков' }.freeze

  # словарь для определения времени суток
  TIMEOFDAY = %w[Ночь Утро День Вечер].freeze

  # дни недели
  WEEKDAYS = %w[Воскресенье Понедельник Вторник Среда Четверг Пятницы Суббота].freeze

  def initialize(params)
    @date = params[:date]
    @tod = params[:tod] # time of day
    @temp_min = params[:temp_min]
    @temp_max = params[:temp_max]
    @cloudiness = params[:cloudiness]
    @max_wind = params[:max_wind]
    @feels_like = params[:feels_like]
    @precipitation = params[:precipitation]
    @weekday = params[:weekday]
  end

  # Метод возвращает необходимые данные прочитанные из XML-структуры с прогнозом погоды
  # @return [MeteoserviceForecast]
  def self.from_xml(node)
    day = node.attributes['day']
    month = node.attributes['month']
    year = node.attributes['year']
    new(
      date: Date.parse("#{day}.#{month}.#{year}"),
      tod: TIMEOFDAY[node.attributes['tod'].to_i],
      weekday: WEEKDAYS[node.attributes['weekday'].to_i - 1],
      temp_min: node.elements['TEMPERATURE'].attributes['min'].to_i,
      temp_max: node.elements['TEMPERATURE'].attributes['max'].to_i,
      cloudiness: node.elements['PHENOMENA'].attributes['cloudiness'].to_i,
      max_wind: node.elements['WIND'].attributes['max'].to_i,
      feels_like: node.elements['HEAT'].attributes['min'].to_i,
      precipitation: node.elements['PHENOMENA'].attributes['precipitation'].to_i
    )
  end

  # Метод вывода данных пользователю
  def to_s
    result = today? ? 'Сегодня' : @date.strftime('%d.%m.%Y')
    result << ", #{@weekday}, #{@tod}\n#{temperature_output}\nветер #{@max_wind} м/с, #{CLOUDINESS[@cloudiness]}, "
    result << (PRECIPITATION[@precipitation]).to_s

    result
  end

  # определение знака +/- для вывода температуры
  def temperature_output
    result = ''
    result << (@temp_min.positive? ? '+' : '-')
    result << "#{@temp_min}.."
    result << (@temp_max.positive? ? '+' : '-')
    result << "#{@temp_max}°C"
    result << (@feels_like.positive? ? ', ощущается как +' : ', ощущается как -')
    result << "#{@feels_like}°C"
    result
  end

  def today?
    @date == Date.today
  end
end
