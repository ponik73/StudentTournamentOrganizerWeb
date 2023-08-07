<?php
    interface IService
    {
        public function getLastErrorMessage();
        public function create($data);
        public function getAll();
        public function getById($data);
        public function remove($data);
    }
?>
