# ######################################################################################################################
#  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.                                                  #
#                                                                                                                      #
#  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance      #
#  with the License. You may obtain a copy of the License at                                                           #
#                                                                                                                      #
#   http://www.apache.org/licenses/LICENSE-2.0                                                                         #
#                                                                                                                      #
#  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed    #
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for   #
#  the specific language governing permissions and limitations under the License.                                      #
# ######################################################################################################################

from typing import Dict, Any

from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext

from shared.sfn_middleware import PersonalizeResource

RESOURCE = "recommender"
STATUS = "recommender.status"
CONFIG = {
    "name": {
        "source": "event",
        "path": "serviceConfig.name",
    },
    "datasetGroupArn": {
        "source": "event",
        "path": "serviceConfig.datasetGroupArn",
    },
    "recipeArn": {"source": "event", "path": "serviceConfig.recipeArn"},
    "recommenderConfig": {
        "source": "event",
        "path": "serviceConfig.recommenderConfig",
        "default": "omit",
    },
    "timeStarted": {
        "source": "event",
        "path": "workflowConfig.timeStarted",
        "default": "omit",
        "as": "iso8601",
    },
    "tags": {
        "source": "event",
        "path": "workflowConfig.tags",
        "default": "omit",
    },
}

logger = Logger()
tracer = Tracer()
metrics = Metrics()


@metrics.log_metrics
@tracer.capture_lambda_handler
@PersonalizeResource(
    resource=RESOURCE,
    status=STATUS,
    config=CONFIG,
)
def lambda_handler(event: Dict[str, Any], context: LambdaContext) -> Dict:
    """Create a recommender in Amazon Personalize based on the configuration in `event`
    :param event: AWS Lambda Event
    :param context: AWS Lambda Context
    :return: the configured dataset
    """
    return event.get("resource")  # return the dataset
