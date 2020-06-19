module SeisNoiseAWS

using Logging
using CSV
using DataFrames
using Dates

# using Distributed
# using SeisNoise


# The functions we want to export out of the module
export load_parameter_file
export load_station_file
export build_availability_df

# struct MyType
#     x
# end
#
# bar(x) = 2x
# foo(a::MyType) = bar(a.x) + 1
#
# show(io::IO, a::MyType) = print(io, "MyType $(a.x)")

# ==============================================================================
function load_parameter_file(filename)
    @info("Loading: $filename")
    @assert(isfile(filename),"Parameter file does not exist.")
    df = DataFrame( CSV.File(filename, missingstring="", delim=",", header=1, type=Float64, normalizenames=true) )
    @info("Done")
    show(df,summary=false); println()
    return df
end
# ==============================================================================
function load_station_file(filename)
    @info("Loading: $filename")
    @assert(isfile(filename),"Station file does not exist.")
    df = DataFrame( CSV.File(filename, missingstring="", delim=",", header=1, normalizenames=true) )
    @info("Done")
    show(df,summary=false); println()
    return df
end
# ==============================================================================
function build_availability_df(df_st)

    # Compute the station tags
    station_tag = build_station_tags(df_st)
    @info("station_tags",station_tag)

    df_date = fill_days(df_st, station_tag)
    return df_date
end
# ==============================================================================
function build_cor_directory(input_dir)
    # Save correlation files to this directory
    COR_DIR = joinpath(input_dir, "CORR") # local path
    if !isdir(COR_DIR) # make the local directoy if necessary
        mkpath(COR_DIR)
    end
    @info("Saving correlations to $COR_DIR")
    return COR_DIR
end

# ==============================================================================
# ==============================================================================
# Internal functions to those in this module
# ==============================================================================
# ==============================================================================
function build_date_range(df_st)
    # Use oldest to youngest dates for the date df
    date_range = collect( findmin( df_st.StartDate )[1] : Dates.Day(1) : findmax( df_st.EndDate )[1])
    num_days   = length(date_range) # number of days of data
    @info("Total number of days of data: $num_days")
    return date_range
end
# ==============================================================================
function build_station_tags(df_st)

    num_data    = nrow(df_st) # number of data in the IRIS query (channels are separate)
    station_tag = Array{String,1}(undef,num_data) # allocate station_tag

    for ii in 1:num_data
        if ismissing(df_st.Location[ii])
            station_tag[ii] = string(df_st.Network[ii], ".", df_st.Station[ii], ".", ".", df_st.Channel[ii]) # create the station ID
        else
            station_tag[ii] = string(df_st.Network[ii], ".", df_st.Station[ii], ".", df_st.Location[ii], ".", df_st.Channel[ii]) # create the station ID
        end
        @info("Creating tag: ", station_tag[ii])
    end
    return station_tag
end
# ==============================================================================
function fill_days(df_st, station_tag)

    # Get the date vector
    date_range = build_date_range(df_st)
    num_days   = length(date_range)
    num_data   = nrow(df_st) # number of data in the IRIS query (channels are separate)

    # Create the station vs. date dataframe
    df_date = DataFrame() # create empy df
    df_date[!, Symbol("station_tag")] = station_tag # column 1 is the station_tag
    # add the other column names and set column values
    for d in date_range
        df_date[!, Symbol(d)] .= false
    end

    st_ends   = Array{Date,1}(df_st.EndDate) # start times of each station_tag
    st_starts = Array{Date,1}(df_st.StartDate) # start times of each station_tag

    # Now populate each row with TRUE/FALSE
    for ii in 1:num_data
        @info("Adding data days for: ", station_tag[ii])
        idx = ( (st_starts[ii] .<= date_range) + (st_ends[ii] .>= date_range) .== 2)
        df_date[ii, 2:num_days+1] .= idx
    end

    return df_date
end

end
