#!/bin/bash

# Configuration

CALAMARIS=/usr/local/calamaris/calamaris
CONF=/usr/local/calamaris/calamaris.conf

# Logs are picked up from the log archive directory. See /etc/cron.daily/squid.daily.job
LOG_DIR=/var/log/squid
ACCESS_LOG="${LOG_DIR}/access.log"

CURRENT_REPORTS_DIR=/var/lib/calamaris/reports
PREVIOUS_REPORTS_DIR="${CURRENT_REPORTS_DIR}/previous"

CACHE=/var/lib/calamaris/cache

BZCAT=`which bzcat`
CAT=`which cat`

LOGSPLIT=/usr/local/bin/rename_squid_logs.pl

FILE_EXPORT_PATH=/var/www/html/proxy_reports

DAILY_REPORT_LABEL=daily
WEEKLY_REPORT_LABEL=weekly
MONTHLY_REPORT_LABEL=monthly


# Options for calamaris

DEFAULT_ARGUMENTS="
--errorcode-distribution-report \
--input-format squid-extended \
--hostname "proxy.local" \
--peak-report new \
--response-time-report \
--size-distribution-report 10 \
--status-report \
--type-report-ignore-case"

# When generating cache files, keep don't limit the length of reports
CACHE_ARGUMENTS="${DEFAULT_ARGUMENTS} \
--benchmark 50000 \
--domain-report -1 \
--performance-report 60 \
--requester-report -1 \
--type-report -1"

# Limit the length of reports for general consumption - to limit privacy issues
OUTPUT_ARGUMENTS="${DEFAULT_ARGUMENTS} \
--benchmark 10000 \
--domain-report 50 \
--requester-report 50 \
--type-report 50 \
--output-format html \
--image-type gif"


############
# functions

# date adjusts to the given number of days in the past and
# formatted using the provided formatting string
# usage: pastDate <minus no. days> <format>
pastDate()
{
    if [ ! $1 ]
    then
        exit 1
    fi
    if [ ! $2 ]
    then
        exit 1
    fi
    if [ `uname` = "Darwin" ]
    then
        echo $(date -v -"$1"d +"$2")
    fi
    if [ `uname` = "Linux" ]
    then
        echo $(date --date="$1 day ago" +"$2")
    fi
}


# Dates

# these dates relate to the log files, i.e. yesterdays logs and activity.
DAY_OF_WEEK=$(pastDate 1 %w)
WEEK=$(pastDate 1 %U)
MONTH=$(pastDate 1 %m)
YEAR=$(pastDate 1 %Y)
DATE=$(pastDate 1 %F)
PREV_DATE="$(($YEAR - 1))${DATE:(-6)}"
PREV_PREV_DATE="$(($YEAR - 2))${DATE:(-6)}"

# if today is the 1st of the month, then yesterday was the end of the month
MONTH_ENDED=$(
    test $(date +%d) = 01 && echo true
)


# Process and Cache Log Data

cd "${CACHE}"
if [ -f "${ACCESS_LOG}.${DAY_OF_WEEK}.bz2" ]
then
    $BZCAT "${ACCESS_LOG}.${DAY_OF_WEEK}.bz2" | $LOGSPLIT
    echo "Generating daily cache file"
    $CAT "${CACHE}/access.${DATE}" | \
    	nice -n ${NICENESS} "${CALAMARIS}" \
    	${CACHE_ARGUMENTS} \
    	--cache-output-file "${CACHE}/cache.${DATE}" > /dev/null
    rm "${CACHE}/access.${DATE}"
    echo
else
    echo "WARNING: No cache found for ${DATE}"
fi

# Create Daily HTML Report

if [ -d "${DAILY_DIR}/${PREV_DATE}" ]
then
    echo "Moving previous Daily HTML report"
    [ -d "${PREV_DAILY_DIR}/${PREV_PREV_DATE}" ] && rm -rf "${PREV_DAILY_DIR}/${PREV_PREV_DATE}"
    mv "${DAILY_DIR}/${PREV_DATE}" "${PREV_DAILY_DIR}/${PREV_DATE}"
fi

echo "Creating Daily HTML Report"

if [ -f "${CACHE}/cache.${DATE}" ]
then
    mkdir -p "${DAILY_DIR}/${DATE}"

    # Get data from the cache file for the most recent day
    nice -n ${NICENESS} "${CALAMARIS}" \
        ${OUTPUT_ARGUMENTS} \
        --no-input \
        --performance-report 60 \
        --cache-input-file "${CACHE}/cache.${DATE}" \
        --output-path "${DAILY_DIR}/${DATE}"
    echo
else
    echo "WARNING: No cache found for ${DATE}"
fi


# Create Weekly Report

if [ $DAY_OF_WEEK -eq 6 ]
then

    if [ -d "${WEEKLY_DIR}/${WEEK}" ]
    then
        echo "Moving previous Weekly HTML report"
        if [ -d "${PREV_WEEKLY_DIR}/${WEEK}" ]
        then
            rm -rf "${PREV_WEEKLY_DIR}/${WEEK}"
        fi
        mv "${WEEKLY_DIR}/${WEEK}" "${PREV_WEEKLY_DIR}/${WEEK}"
    fi

    echo "Creating Weekly HTML Report"

    CACHE_FILES=
    DATE_ADJUSTMENT=$(( $DAY_OF_WEEK + 1 ))
    while [ $DATE_ADJUSTMENT -ge 1 ]
    do

        CACHE_DATE=$(pastDate $DATE_ADJUSTMENT %F)

        if [ -f "${CACHE}/cache.${CACHE_DATE}" ]
        then
            if [ $CACHE_FILES ]
            then
                CACHE_FILES="${CACHE_FILES}:"
            fi

            CACHE_FILES="${CACHE_FILES}${CACHE}/cache.${CACHE_DATE}"
        else
            echo "WARNING: No cache found for ${CACHE_DATE}"
            continue
        fi

        DATE_ADJUSTMENT=$(( $DATE_ADJUSTMENT - 1 ))

    done
    if [ $CACHE_FILES ]
    then
        mkdir -p "${WEEKLY_DIR}/${WEEK}"

        nice -n ${NICENESS} "${CALAMARIS}" \
    	    ${OUTPUT_ARGUMENTS} \
        	--no-input \
        	--cache-input-file "${CACHE_FILES}" \
        	--output-path "${WEEKLY_DIR}/${WEEK}"
        echo
    fi

fi


# Create Monthly Report

if [ $MONTH_ENDED ]
then

    if [ -d "${MONTHLY_DIR}/${MONTH}" ]
    then
        echo "Moving previous Monthly HTML report"
        if [ -d "${PREV_MONTHLY_DIR}/${MONTH}" ]
        then
            rm -rf "${PREV_MONTHLY_DIR}/${MONTH}"
        fi
        mv "${MONTHLY_DIR}/${MONTH}" "${PREV_MONTHLY_DIR}/${MONTH}"
    fi

    echo "Creating Monthly HTML Report"

    CACHE_FILES=
    for CACHE_FILE in $(ls "${CACHE}"/cache.${YEAR}-${MONTH}-*)
    do

        if [ $CACHE_FILES ]
        then
            CACHE_FILES="${CACHE_FILES}:"
        fi

        CACHE_FILES="${CACHE_FILES}${CACHE_FILE}"

    done

    if [ $CACHE_FILES ]
    then

        mkdir -p "${MONTHLY_DIR}/${MONTH}"

        nice -n ${NICENESS} "${CALAMARIS}" \
            ${OUTPUT_ARGUMENTS} \
            --no-input \
        	--cache-input-file "${CACHE_FILES}" \
        	--output-path "${MONTHLY_DIR}/${MONTH}"
        echo

    fi

fi


# Delete old cache files

if [ $MONTH_ENDED ]
then

    echo "Removing old cache files"

    cd "${CACHE}"

    if [ ${MONTH##0} -gt 1 ]
    then
        RM_MONTH=$(printf "%0#2d" $((${MONTH##0} - 1)) )
        RM_YEAR=$YEAR
    else
        RM_MONTH=12
        RM_YEAR=$(($YEAR - 1))
    fi

    for CACHE_FILE in $(ls "${CACHE}"/cache.${RM_YEAR}-${RM_MONTH}-*)
    do
        rm "${CACHE}/${CACHE_FILE}"
    done

fi



# Copy files to web server

echo "Copying files to webroot"
sudo cp -R $CURRENT_REPORTS_DIR/* $FILE_EXPORT_PATH