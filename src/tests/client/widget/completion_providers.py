#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  tests/client/widget/completion_providers.py
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the
#    distribution.
#  * Neither the name of the project nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

import glob
import os
import unittest

from king_phisher import find
from king_phisher import serializers
from king_phisher import testing
from king_phisher.client.widget import completion_providers

class ClientJinjaComletionProviderTests(testing.KingPhisherTestCase):
	def test_get_proposal_terms(self):
		provider = completion_providers.JinjaComletionProvider()

		proposal_strings = completion_providers.get_proposal_terms(
			provider.jinja_tokens,
			['time']
		)
		self.assertIsInstance(proposal_strings, list)
		self.assertNotIn('local', proposal_strings)

		proposal_strings = completion_providers.get_proposal_terms(
			provider.jinja_tokens,
			['time', '']
		)
		self.assertIsInstance(proposal_strings, list)
		self.assertIn('local', proposal_strings)

	def test_load_data_files(self):
		completion_dir = find.data_directory('completion')
		self.assertIsNotNone(completion_dir, 'failed to find the \'completion\' directory')
		# validate that completion definitions claiming to be json are loadable as json
		for json_file in glob.glob(os.path.join(completion_dir, '*.json')):
			json_file = os.path.abspath(json_file)
			with open(json_file, 'r') as file_h:
				try:
					serializers.JSON.load(file_h, strict=True)
				except Exception:
					self.fail("failed to load file '{0}' as json data".format(json_file))

if __name__ == '__main__':
	unittest.main()
